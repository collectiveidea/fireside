ActionDispatch::TestResponse.class_eval do
  def content
    @content ||= Content.new(body, content_type)
  end
end
