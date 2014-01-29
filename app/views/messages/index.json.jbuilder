json.messages @messages do |message|
  json.body message.body
  json.created_at message.created_at
  json.id message.id
  json.room_id message.room_id
  json.type message.type
  json.user_id message.user_id
end
