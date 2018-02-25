class WelcomeController < ApplicationController
	def index
		render json: {amazing: "you reached it"}
	end
end
