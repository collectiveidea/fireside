module ApplicationHelper
  def upload_full_url(upload)
    "#{request.protocol}#{request.host_with_port}#{upload.file.url}"
  end
end
