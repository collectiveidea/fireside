xml.room do
  xml << render(@room)
  xml.tag! "active-token-value", @room.active_token_value
  xml.full @room.full?, type: "boolean"
  xml.tag! "open-to-guests", @room.open_to_guests?, type: "boolean"
  xml.users type: "array" do
    @room.users.each do |user|
      xml.user do
        xml << render(user)
      end
    end
  end
end
