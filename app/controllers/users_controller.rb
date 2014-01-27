class UsersController < ApplicationController
  skip_before_action :authenticate_by_token, only: [:current]
  before_action :authenticate_by_token_or_login, only: [:current]

  def show
    @user = User.find(params[:id])
  end

  def current
    @user = current_user
  end

  private

  def authenticate_by_token_or_login
    authenticate_or_request_with_http_basic do |username, password|
      if user = User.find_by(api_auth_token: username)
        self.current_user = user
      elsif user = User.find_by(email: username)
        self.current_user = user.authenticate(password)
      end
    end
  end
end
