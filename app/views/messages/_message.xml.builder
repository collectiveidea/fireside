xml.body message.body
xml.tag! "created-at", message.created_at, type: "datetime"
xml.id message.id, type: "integer"
xml.tag! "room-id", message.room_id, type: "integer"
xml.type message.type
xml.tag! "user-id", message.user_id, type: "integer"
