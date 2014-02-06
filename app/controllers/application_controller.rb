class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActionController::ParameterMissing, ActionController::UnpermittedParameters do
    head :bad_request
  end

  before_action :authenticate

  attr_accessor :current_user

  private

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      if user = User.find_by(api_auth_token: username)
        self.current_user = user
      elsif user = User.find_by(email: username)
        self.current_user = user.authenticate(password)
      end
    end
  end
end
