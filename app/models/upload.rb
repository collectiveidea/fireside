class Upload < ActiveRecord::Base
  belongs_to :user, inverse_of: :uploads
  belongs_to :room, inverse_of: :uploads

  has_attached_file :file

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
