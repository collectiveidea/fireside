class MessagesController < ApplicationController
  def index
    @messages = Message.old_to_new
  end

  def show
    @message = Message.find(params[:id])
  end
end
