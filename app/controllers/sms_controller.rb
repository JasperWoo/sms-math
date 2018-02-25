require 'redis'
require 'twilio-ruby'
class SmsController < ApplicationController
	skip_before_action :verify_authenticity_token
  #TODO-v2: possibly do a 'who answers first who gets the win'
  #TODO-v1: gradually harder questions
  #TODO-v1: prevent doing the same question
  #TODO-v1: add more questions in the future.
  #POST /sms/register
  def reply
    body_arr = params[:Body].split(' ')
    method = body_arr[0]
    if method.upcase == 'REGISTER'
      p "Registering User #{body_arr[1]} from #{params[:From]}"
      User.register(params[:From], body_arr[1])
      send_sms(params[:From], "User registered. Hello #{body_arr[1]}!")
      Thread.new(params[:From], &method(:send_question))
      head 201 && return    # Response is given to Twilio server for possible future use. 
    elsif User.get(params[:From], 'name').nil?
      p 'User does not exist!'

      send_sms(params[:From], "Please register with the form 'REGISTER <name>'.")
      head 404 && return
    else 
      # process answer
      answer = method
      p "Processing answer #{answer}"
      #TODO-v1: critical section to prevent user from keeping hitting the endpoint 
      if answer == Question.get(User.get(params[:From], 'curr_ques_id'), 'answer')
        prev_count = User.get(params[:From], 'count')
        User.update(params[:From], 'count', prev_count.to_i + 1)
        if User.get(params[:From], 'count') == '5' #TODO: dynamic number
          send_sms(params[:From], 'Congratulations, you hit 5 question! Reward is sent. Answered question is cleared to 0')
          User.update(params[:From], 'count', 0)  
        else
          send_sms(params[:From], "Answer recorded.\nYou have answered #{User.get(params[:From], 'count')} questions correctly.")
        end
      else 
        send_sms(params[:From], "Wrong answer.\nDon't be upset. You still have answered #{User.get(params[:From], 'count')} questions correctly.")
      end
      User.update(params[:From], 'curr_ques_id', '-1') # So that user cannot answer the same question again and again! Fixed the repeat msg problem      
      Thread.new(params[:From], &method(:send_question))
      head 204 && return
    end
  end

  def send_sms(phone, msg)
    account_sid = ENV['TWILIO_ACCOUNT_SID'] 
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    @client = Twilio::REST::Client.new account_sid, auth_token
    @client.messages.create(
        body: msg,
        to: phone,    # Replace with your phone number
        from: ENV['TWILIO_PHONE_NUMBER'])  # Replace with your Twilio number 
  end
  

  def send_question(phone)

    while true 
      sleep 0.5
      ques_key = SecureRandom.random_number(100)
      ques_body = Question.get(ques_key, 'body') #TODO: dynmic cap
      p 'question not found!' unless ques_body
      next unless ques_body
      p '!!!!!!!!!Mined a question!!!!!!!!' 
      User.update(phone, 'curr_ques_id', ques_key)
      send_sms(phone, "\nNew question:\n" + ques_body + "\nYou have answered " + User.get(phone, 'count') + ' questions correctly')
      break
    end
    
  end

end


