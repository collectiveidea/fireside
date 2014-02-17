xml.tag! "created-at", room.created_at.xmlschema, type: "datetime"
xml.id room.id, type: "integer"
xml.locked room.locked?, type: "boolean"
xml.tag! "membership-limit", room.membership_limit, type: "integer"
xml.name room.name
xml.topic room.topic
xml.tag! "updated-at", room.updated_at.xmlschema, type: "datetime"
