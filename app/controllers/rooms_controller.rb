class RoomsController < ApplicationController
  before_action :load_room, except: [:index, :current]

  def index
    @rooms = Room.old_to_new
  end

  def current
    @rooms = current_user.rooms.old_to_new
    render :index
  end

  def show
  end

  def update
    @room.update(room_params)
    head :ok
  end

  def join
    if @room.unlocked? || current_user.admin?
      current_user.presences.find_or_create_by!(room_id: @room.id)
      head :ok
    else
      head :locked
    end
  end

  def leave
    current_user.presences.where(room_id: @room.id).destroy_all
    head :ok
  end

  def lock
    @room.lock
    head :ok
  end

  def unlock
    @room.unlock
    head :ok
  end

  private

  def load_room
    @room = Room.find(params[:id])
  end

  def room_params
    params.require(:room).permit(:name, :topic, :open_to_guests)
  end
end
