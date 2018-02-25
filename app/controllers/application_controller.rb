class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  def index
		render json: {'hi': "you found me"}
  end
end
