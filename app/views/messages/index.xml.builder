xml.messages type: "array" do
  @messages.each do |message|
    xml << render("message", message: message)
  end
end
