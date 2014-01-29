json.room do
  json.active_token_value @room.active_token_value
  json.created_at @room.created_at
  json.full @room.full?
  json.id @room.id
  json.locked @room.locked?
  json.membership_limit @room.membership_limit
  json.name @room.name
  json.open_to_guests @room.open_to_guests?
  json.topic @room.topic
  json.updated_at @room.updated_at
  json.users @room.users do |user|
    json.partial! user
  end
end
