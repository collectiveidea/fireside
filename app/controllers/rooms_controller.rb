class RoomsController < ApplicationController
  before_action :load_room, except: [:index, :presence]

  def index
    @rooms = Room.old_to_new
  end

  def presence
    # TODO
  end

  def show
  end

  def update
    @room.update(room_params)
    head :ok
  end

  def join
    # TODO
  end

  def leave
    # TODO
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
