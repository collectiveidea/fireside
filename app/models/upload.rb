class Upload < ActiveRecord::Base
  belongs_to :user, inverse_of: :uploads
  belongs_to :room, inverse_of: :uploads

  has_attached_file :file, url: "/files/:fingerprint.:extension"

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
