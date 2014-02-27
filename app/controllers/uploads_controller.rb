class UploadsController < ApplicationController
  rescue_from Paperclip::Error do
    head :unprocessable_entity
  end

  before_action :load_room

  def index
    if current_user.admin? || current_user.in_room?(@room) || @room.unlocked?
      @uploads = Upload.for_room(@room)
    else
      head :locked
    end
  end

  def show
    if current_user.admin? || current_user.in_room?(@room) || @room.unlocked?
      @upload = Upload.for_message(params[:message_id])
    else
      head :locked
    end
  end

  def create
    @upload = @room.upload_file_for_user(params[:upload], current_user)

    if @upload.persisted?
      message = UploadMessage.post(current_user, @room)
      @upload.attach_to_message(message)

      render :show, status: :created
    else
      head :unprocessable_entity
    end
  end

  private

  def load_room
    @room = Room.find(params[:room_id])
  end
end
