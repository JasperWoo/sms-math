Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'application#index'
  post '/sms/reply', to: 'sms#reply' 
#  post '/sms/reply', to: redirect { |params, req| "/sms/#{params[:Body].split(' ')[0]}"}
end
