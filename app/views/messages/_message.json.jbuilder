json.body message.body
json.created_at message.created_at
json.id message.id
json.room_id message.room_id
json.starred message.starred?
json.type message.type
json.user_id message.user_id

case message
when SoundMessage
  json.description message.description
  json.url message.url
when TweetMessage
  json.tweet message.metadata
end
