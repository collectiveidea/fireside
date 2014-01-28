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

  describe ".create_for_room" do
    it "creates a message for the given room" do
      room = create(:room)

      expect {
        Message.create_for_room(room, body: "Hello, world!")
      }.to change {
        Message.count
      }.from(0).to(1)

      message = Message.last

      expect(message.body).to eq("Hello, world!")
      expect(message).not_to be_private
    end

    it "creates a private message for a locked room" do
      room = create(:room, :locked)

      expect {
        Message.create_for_room(room, body: "Hello, world!")
      }.to change {
        Message.count
      }.from(0).to(1)

      message = Message.last

      expect(message.body).to eq("Hello, world!")
      expect(message).to be_private
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

  describe "#unstar" do
    it "sets starred to false and saves" do
      message = create(:message, starred: true)

      expect {
        message.unstar
      }.to change {
        message.reload.starred?
      }.from(true).to(false)
    end
  end
end
