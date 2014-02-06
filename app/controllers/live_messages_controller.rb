class LiveMessagesController < ApplicationController
  include ActionController::Live

  before_action :load_room

  def index
    @room.on_message do |payload|
      if payload
        response.stream.write(render_to_body(
          partial: "messages/message",
          locals: { message: payload }
        ))
      else
        response.stream.write(" ")
      end
    end
  rescue IOError
    # Client closed connection
  ensure
    response.stream.close
  end

  private

  def load_room
    @room = Room.find(params[:room_id])
  end
end
