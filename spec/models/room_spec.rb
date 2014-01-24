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
end
