class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end

  def current
    # TODO
  end
end
