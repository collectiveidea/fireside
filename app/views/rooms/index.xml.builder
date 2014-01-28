xml.rooms type: "array" do
  @rooms.each do |room|
    xml.room do
      xml.tag! "created-at", room.created_at, type: "datetime"
      xml.id room.id, type: "integer"
      xml.locked room.locked?, type: "boolean"
      xml.tag! "membership-limit", room.membership_limit, type: "integer"
      xml.name room.name
      xml.topic room.topic
      xml.tag! "updated-at", room.updated_at, type: "datetime"
    end
  end
end
