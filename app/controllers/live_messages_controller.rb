class LiveMessagesController < ApplicationController
  include ActionController::Live

  before_action :load_room

  def index
    respond_to do |format|
      format.any(:json, :xml) do
        on_message do |message|
          response.stream.write(message_chunk(message))
        end
      end

      format.sse do
        missed_messages.each do |message|
          response.stream.write(message_event(message))
        end

        on_message do |message|
          response.stream.write(message_event(message))
        end
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

  def on_message
    @room.on_message do |message|
      if message
        yield message
      else
        response.stream.write(" ")
      end
    end
  end

  def message_chunk(message)
    render_to_body(
      partial: "messages/message",
      locals: { message: message }
    )
  end

  def message_event(message)
    data = render_to_body(
      partial: "messages/message.json",
      locals: { message: message }
    )

    <<-SSE.strip_heredoc
      id: #{message.id}
      event: message
      data: #{data}

      SSE
  end

  def missed_messages
    last_event_id ? @room.messages.after_id(last_event_id) : []
  end

  def last_event_id
    request.headers["Last-Event-ID"].try(:to_i)
  end
end
