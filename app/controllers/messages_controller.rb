class MessagesController < ApplicationController
  def index
    @messages = Message.old_to_new
  end

  def create
    @message = Message.create!(message_params)
    render :show, status: :created
  end

  private

  def message_params
    params.require(:message).permit(:body)
  end
end
