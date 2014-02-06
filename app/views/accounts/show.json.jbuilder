json.account do
  json.created_at @timestamp
  json.id 1
  json.name ENV["HOST"]
  json.owner_id nil
  json.plan nil
  json.subdomain nil
  json.storage 0
  json.time_zone @time_zone
  json.updated_at @timestamp
end
