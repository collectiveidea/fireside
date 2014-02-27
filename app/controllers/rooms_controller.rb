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
    respond_to do |format|
      format.html do
        @messages = @room.messages.recent
      end

      format.any
    end
  end

  def update
    @room.update(room_params)
    head :ok
  end

  def join
    if current_user.admin? || @room.unlocked?
      unless current_user.in_room?(@room)
        current_user.join_room(@room)
        EnterMessage.post(current_user, @room)
      end

      head :ok
    else
      head :locked
    end
  end

  def leave
    if current_user.in_room?(@room)
      current_user.leave_room(@room)
      LeaveMessage.post(current_user, @room)
    end

    head :ok
  end

  def lock
    if @room.unlocked?
      LockMessage.post(current_user, @room)
      @room.lock
    end

    head :ok
  end

  def unlock
    if @room.locked?
      if current_user.admin? || current_user.in_room?(@room)
        @room.clean
        @room.unlock
        UnlockMessage.post(current_user, @room)

        head :ok
      else
        head :locked
      end
    else
      head :ok
    end
  end

  private

  def load_room
    @room = Room.find(params[:id])
  end

  def room_params
    params.require(:room).permit(:name, :topic, :open_to_guests)
  end
end
