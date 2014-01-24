class Message < ActiveRecord::Base
  validates :body, presence: true
end
