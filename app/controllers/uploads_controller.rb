class UploadsController < ApplicationController
  before_action :load_room

  def index
    @uploads = @room.uploads.old_to_new
  end

  def create
    @upload = @room.upload_file_for_user(params[:upload], current_user)
    render :show, status: :created
  end

  private

  def load_room
    @room = Room.find(params[:room_id])
  end
end
