xml.rooms type: "array" do
  @rooms.each do |room|
    xml.room do
      xml << render(room)
    end
  end
end
