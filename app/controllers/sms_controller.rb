class SmsController < ApplicationController
	def index
		render json: {'hi': "you found me"}
  end
end
