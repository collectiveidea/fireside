xml.uploads type: "array" do
  @uploads.each do |upload|
    xml.upload do
      xml << render(upload)
    end
  end
end
