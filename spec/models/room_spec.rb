require "spec_helper"

describe Room do
  describe ".old_to_new" do
    it "orders rooms oldest to newest" do
      rooms = [
        create(:room, created_at: 2.days.ago),
        create(:room, created_at: 3.days.ago),
        create(:room, created_at: 1.day.ago)
      ]

      expect(Room.old_to_new).to eq(rooms.sort_by(&:created_at))
    end
  end

  describe "#lock" do
    it "sets locked to true and saves" do
      room = create(:room, locked: false)

      expect {
        room.lock
      }.to change {
        room.reload.locked?
      }.from(false).to(true)
    end
  end

  describe "#unlock" do
    it "sets locked to false and saves" do
      room = create(:room, locked: true)

      expect {
        room.unlock
      }.to change {
        room.reload.locked?
      }.from(true).to(false)
    end
  end

  describe "#unlocked?" do
    it "is the opposite of #locked?" do
      locked = create(:room, locked: true)
      unlocked = create(:room, locked: false)

      expect(locked.unlocked?).to be_false
      expect(unlocked.unlocked?).to be_true
    end
  end

  describe "#clean" do
    it "destroys all private messages" do
      room = create(:room)
      message_1 = create(:message, room: room)
      create(:message, :private, room: room)
      message_3 = create(:message, room: room)
      create(:message, :private, room: room)

      expect {
        room.clean
      }.to change {
        room.messages.count
      }.from(4).to(2)

      expect(room.messages).to match_array([message_1, message_3])
    end
  end
end
