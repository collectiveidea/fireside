require "spec_helper"

describe Message do
  describe ".old_to_new" do
    it "orders messages oldest to newest" do
      messages = [
        create(:message, created_at: 2.minutes.ago),
        create(:message, created_at: 3.minutes.ago),
        create(:message, created_at: 1.minute.ago)
      ]

      expect(Message.old_to_new).to eq(messages.sort_by(&:created_at))
    end
  end

  describe "#star" do
    it "sets starred to true and saves" do
      message = create(:message, starred: false)

      expect {
        message.star
      }.to change {
        message.reload.starred?
      }.from(false).to(true)
    end
  end
end
