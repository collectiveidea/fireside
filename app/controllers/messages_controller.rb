class MessagesController < ApplicationController
  before_action :load_room, only: [:index, :today, :create]
  before_action :load_message, only: [:star, :unstar]

  def index
    @messages = @room.messages.recent
  end

  def today
    @messages = @room.messages.today
    render :index
  end

  def create
    @message = Message.post(current_user, @room, message_params)

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
    params.require(:message).permit(:body, :type)
  end

  def load_message
    @message = Message.find(params[:id])
  end
end
