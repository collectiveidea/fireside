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
    # TODO
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
    # TODO
  end

  private

  def load_room
    @room = Room.find(params[:id])
  end
end
