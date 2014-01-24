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
            "membership_limit" => room_1.membership_limit,
            "name" => room_1.name,
            "topic" => room_1.topic,
            "updated_at" => room_1.updated_at.as_json
          },
          {
            "created_at" => room_2.created_at.as_json,
            "id" => room_2.id,
            "locked" => room_2.locked?,
            "membership_limit" => room_2.membership_limit,
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
    it "shows the room" do
      room = create(:room, :with_guest_access, :locked)

      get "/room/#{room.id}.json"

      expect(response.status).to eq(200)
      expect(response.json).to eq(
        "room" => {
          "active_token_value" => room.active_token_value,
          "created_at" => room.created_at.as_json,
          "full" => room.full?,
          "id" => room.id,
          "locked" => room.locked?,
          "membership_limit" => room.membership_limit,
          "name" => room.name,
          "open_to_guests" => room.open_to_guests?,
          "topic" => room.topic,
          "updated_at" => room.updated_at.as_json
        }
      )
    end
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
