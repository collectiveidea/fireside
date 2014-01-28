xml.room do
  xml.tag! "active-token-value", @room.active_token_value
  xml.tag! "created-at", @room.created_at, type: "datetime"
  xml.full @room.full?, type: "boolean"
  xml.id @room.id, type: "integer"
  xml.locked @room.locked?, type: "boolean"
  xml.tag! "membership-limit", @room.membership_limit, type: "integer"
  xml.name @room.name
  xml.tag! "open-to-guests", @room.open_to_guests?, type: "boolean"
  xml.topic @room.topic
  xml.tag! "updated-at", @room.updated_at, type: "datetime"
end
