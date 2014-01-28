xml.message do
  xml.body @message.body
  xml.tag! "created-at", @message.created_at, type: "datetime"
  xml.id @message.id, type: "integer"
  xml.room_id @message.room_id, type: "integer"
end
