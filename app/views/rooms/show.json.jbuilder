json.room do
  json.partial! @room
  json.active_token_value @room.active_token_value
  json.full @room.full?
  json.open_to_guests @room.open_to_guests?
  json.users @room.users do |user|
    json.partial! user
  end
end
