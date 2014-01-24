class MessagesController < ApplicationController
  def show
    @message = Message.find(params[:id])
  end
end
