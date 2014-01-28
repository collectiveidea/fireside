class MessagesController < ApplicationController
  before_action :load_room, only: [:index, :create]
  before_action :load_message, only: [:star, :unstar]

  def index
    @messages = @room.messages.old_to_new
  end

  def create
    @message = Message.create_for_room(@room, message_params)
    render :show, status: :created
  end

  def star
    @message.star
    head :ok
  end

  def unstar
    @message.unstar
    head :ok
  end

  private

  def load_room
    @room = Room.find(params[:room_id])
  end

  def message_params
    params.require(:message).permit(:body)
  end

  def load_message
    @message = Message.find(params[:id])
  end
end
