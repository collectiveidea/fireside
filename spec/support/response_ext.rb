ActionDispatch::TestResponse.class_eval do
  def json
    @json ||= JSON.load(body).deep_symbolize_keys
  end
end
