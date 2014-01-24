json.rooms @rooms do |room|
  json.created_at room.created_at
  json.id room.id
  json.locked room.locked?
  json.membership_limit room.membership_limit
  json.name room.name
  json.topic room.topic
  json.updated_at room.updated_at
end
