xml.message do
  xml.body message.body
  xml.tag! "created-at", message.created_at, type: "datetime"
  xml.id message.id, type: "integer"
  xml.tag! "room-id", message.room_id, type: "integer"
  xml.starred message.starred?, type: "boolean"
  xml.type message.type
  xml.tag! "user-id", message.user_id, type: "integer"

  case message
  when SoundMessage
    xml.description message.description
    xml.url message.url
  end
end
