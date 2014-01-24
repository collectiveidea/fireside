class MessagesController < ApplicationController
  before_action :load_room

  def index
    @messages = @room.messages.old_to_new
  end

  def create
    @message = @room.messages.create!(message_params)
    render :show, status: :created
  end

  private

  def load_room
    @room = Room.find(params[:room_id])
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
