class Message < ActiveRecord::Base
  validates :body, presence: true

  def self.old_to_new
    order(:created_at)
  end
end
