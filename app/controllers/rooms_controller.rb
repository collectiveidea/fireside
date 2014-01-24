class RoomsController < ApplicationController
  def index
    @rooms = Room.old_to_new
  end

  def presence
    # TODO
  end

  def show
    # TODO
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
    # TODO
  end

  def unlock
    # TODO
  end
end
