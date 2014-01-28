ActionDispatch::TestResponse.class_eval do
  def json
    @json ||= JSON.load(body)
  end

  def content
    @content ||= Content.new(body, content_type)
  end
end
