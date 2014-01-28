class MessagesController < ApplicationController
  before_action :load_room, only: [:index, :create]
  before_action :load_message, only: [:star, :unstar]

  def index
    @messages = @room.messages.old_to_new
  end

  def create
    @message = Message.create_for_room(@room, message_params)

    if @message.persisted?
      render :show, status: :created
    else
      respond_to do |format|
        format.json do
          render json: @message.errors, status: :unprocessable_entity
        end

        format.xml do
          render xml: @message.errors, status: :unprocessable_entity
        end
      end
    end
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
