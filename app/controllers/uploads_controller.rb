class UploadsController < ApplicationController
  before_action :load_room

  def index
    @uploads = @room.uploads.old_to_new
  end

  def create
    @upload = @room.upload_file_for_user(params[:upload], current_user)
    UploadMessage.post(current_user, @room, @upload)
    render :show, status: :created
  end

  def show
    message = @room.messages.find(params[:message_id])
    @upload = @room.uploads.find(message.metadata["upload_id"])
  end

  private

  def load_room
    @room = Room.find(params[:room_id])
  end
end
