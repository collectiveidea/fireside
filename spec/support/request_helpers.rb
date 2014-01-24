module RequestHelpers
  def post_json(path, json)
    post path, json, "CONTENT_TYPE" => "application/json"
  end
end

RSpec.configure do |config|
  config.include(RequestHelpers)
end
