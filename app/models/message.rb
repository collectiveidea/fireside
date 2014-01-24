class Message < ActiveRecord::Base
  belongs_to :room, inverse_of: :messages

  validates :body, presence: true

  def self.old_to_new
    order(:created_at)
  end
end
