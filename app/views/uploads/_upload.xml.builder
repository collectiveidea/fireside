xml.tag! "byte-size", upload.byte_size, type: "integer"
xml.tag! "content-type", upload.content_type
xml.tag! "created-at", upload.created_at, type: "datetime"
xml.id upload.id, type: "integer"
xml.name upload.name
xml.tag! "room-id", upload.room_id, type: "integer"
xml.tag! "user-id", upload.user_id, type: "integer"
