module HasPaperclip
  def paperclip_options
    using_s3? ? s3_options : filesystem_options
  end

  def using_s3?
    ENV.values_at("S3_BUCKET", "S3_ACCESS_KEY_ID", "S3_SECRET_ACCESS_KEY").all?(&:present?)
  end

  def s3_options
    {
      path: "/uploads/:fingerprint.:extension",
      s3_credentials: {
        bucket: ENV["S3_BUCKET"],
        access_key_id: ENV["S3_ACCESS_KEY_ID"],
        secret_access_key: ENV["S3_SECRET_ACCESS_KEY"]
      },
      s3_protocol: "https",
      storage: :s3,
      url: ":s3_domain_url"
    }
  end

  def filesystem_options
    { url: "/uploads/:fingerprint.:extension" }
  end
end
