class Upload < ActiveRecord::Base
  extend HasPaperclip

  belongs_to :user, inverse_of: :uploads
  belongs_to :room, inverse_of: :uploads
  belongs_to :message

  validates :message_id, uniqueness: { allow_nil: true }

  has_attached_file :file, paperclip_options

  validates :user_id, :room_id, presence: true, strict: true
  validates_attachment :file, presence: true
  do_not_validate_attachment_file_type :file

  def self.for_room(room)
    where(room_id: room).order(:created_at).limit(5)
  end

  def self.for_message(message)
    where(message_id: message).first!
  end

  def attach_to_message(message)
    self.message = message
    save!
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
