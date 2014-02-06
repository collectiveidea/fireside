xml.account do
  xml.tag! "created-at", @timestamp, type: "datetime"
  xml.id 1, type: "integer"
  xml.name ENV["HOST"]
  xml.tag! "owner-id", nil
  xml.plan nil
  xml.subdomain nil
  xml.storage 0, type: "integer"
  xml.tag! "time-zone", @time_zone
  xml.tag! "updated-at", @timestamp, type: "datetime"
end
