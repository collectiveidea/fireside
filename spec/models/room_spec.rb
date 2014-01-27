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
      message = create(:room, locked: false)

      expect {
        message.lock
      }.to change {
        message.reload.locked?
      }.from(false).to(true)
    end
  end

  describe "#unlock" do
    it "sets locked to false and saves" do
      message = create(:room, locked: true)

      expect {
        message.unlock
      }.to change {
        message.reload.locked?
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
end
