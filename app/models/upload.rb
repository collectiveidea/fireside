class Upload < ActiveRecord::Base
  extend HasPaperclip

  belongs_to :user, inverse_of: :uploads
  belongs_to :room, inverse_of: :uploads

  has_attached_file :file, paperclip_options

  validates :user_id, :room_id, presence: true, strict: true
  validates_attachment :file, presence: true
  do_not_validate_attachment_file_type :file

  def self.old_to_new
    order(:created_at)
  end

  def byte_size
    file.size
  end

  def content_type
    file.content_type
  end

  def full_url
    url = file.url
    url =~ /^http/ ? url : "#{ENV["PROTOCOL"]}://#{ENV["HOST"]}#{url}"
  end

  def name
    file.original_filename
  end
end
