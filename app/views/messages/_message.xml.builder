xml.message do
  xml.body message.body
  xml.tag! "created-at", message.created_at.xmlschema, type: "datetime"
  xml.id message.id, type: "integer"
  xml.tag! "room-id", message.room_id, type: "integer"
  xml.starred message.starred?, type: "boolean"
  xml.type message.type
  xml.tag! "user-id", message.user_id, type: "integer"

  case message
  when SoundMessage
    xml.description message.description
    xml.url message.url
  when TweetMessage
    xml.tweet do
      xml.tag! "author-avatar-url", message.metadata["author_avatar_url"]
      xml.tag! "author-username", message.metadata["author_username"]
      xml.id message.metadata["id"], type: "integer"
      xml.message message.metadata["message"]
    end
  end
end
