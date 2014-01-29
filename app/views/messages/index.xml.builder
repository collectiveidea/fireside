xml.messages type: "array" do
  @messages.each do |message|
    xml.message do
      xml << render("message", message: message)
    end
  end
end
