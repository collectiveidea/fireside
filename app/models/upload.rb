class Upload < ActiveRecord::Base
  belongs_to :user, inverse_of: :uploads
  belongs_to :room, inverse_of: :uploads

  if ENV["S3_BUCKET"]
    # S3 storage
    has_attached_file :file,
      path: "/uploads/:fingerprint.:extension",
      s3_credentials: {
        bucket: ENV["S3_BUCKET"],
        access_key_id: ENV["S3_ACCESS_KEY_ID"],
        secret_access_key: ENV["S3_SECRET_ACCESS_KEY"]
      },
      s3_protocol: "https",
      storage: :s3,
      url: ":s3_domain_url"
  else
    # Filesystem storage
    has_attached_file :file,
      url: "/uploads/:fingerprint.:extension"
  end

  validates :user_id, :room_id, presence: true, strict: true
  validates_attachment :file, presence: true, size: { in: 0..10.megabytes }

  def self.old_to_new
    order(:created_at)
  end

  def byte_size
    file.size
  end

  def content_type
    file.content_type
  end

  def name
    file.original_filename
  end
end
