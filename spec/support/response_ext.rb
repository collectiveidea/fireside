ActionDispatch::TestResponse.class_eval do
  def json
    @json ||= JSON.load(body)
  end
end
