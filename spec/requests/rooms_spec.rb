require "spec_helper"

describe "Room Requests" do
  describe "GET /rooms" do
    it "lists all rooms" do
      room_1 = create(:room, created_at: 2.days.ago)
      room_2 = create(:room, :locked, created_at: 1.day.ago)

      get "/rooms.json"

      expect(response.status).to eq(200)
      expect(response.json).to eq(
        "rooms" => [
          {
            "created_at" => room_1.created_at.as_json,
            "id" => room_1.id,
            "locked" => room_1.locked?,
            "membership_limit" => 1_000_000,
            "name" => room_1.name,
            "topic" => room_1.topic,
            "updated_at" => room_1.updated_at.as_json
          },
          {
            "created_at" => room_2.created_at.as_json,
            "id" => room_2.id,
            "locked" => room_2.locked?,
            "membership_limit" => 1_000_000,
            "name" => room_2.name,
            "topic" => room_2.topic,
            "updated_at" => room_2.updated_at.as_json
          }
        ]
      )
    end
  end

  describe "GET /presence" do
    pending
  end

  describe "GET /room/:id" do
    pending
  end

  describe "PUT /room/:id" do
    pending
  end

  describe "POST /room/:id/join" do
    pending
  end

  describe "POST /room/:id/leave" do
    pending
  end

  describe "POST /room/:id/lock" do
    pending
  end

  describe "POST /room/:id/unlock" do
    pending
  end
end
