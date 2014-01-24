require "spec_helper"

describe "Room Requests" do
  describe "GET /rooms" do
    let!(:room_1) { create(:room, created_at: 2.days.ago) }
    let!(:room_2) { create(:room, :locked, created_at: 1.day.ago) }

    it "lists all rooms" do
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
    let!(:room) { create(:room, :with_guest_access, :locked) }

    it "shows the room" do
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
    let!(:room) { create(:room, topic: "Hello!") }

    it "updates the room" do
      expect {
        put_json "/room/#{room.id}.json", %({"topic":"Goodbye."})
      }.to change {
        room.reload.topic
      }.from("Hello!").to("Goodbye.")

      expect(response.status).to eq(200)
      expect(response.body).to be_blank
    end
  end

  describe "POST /room/:id/join" do
    pending
  end

  describe "POST /room/:id/leave" do
    pending
  end

  describe "POST /room/:id/lock" do
    let!(:room) { create(:room) }

    it "locks the room" do
      expect {
        post "/room/#{room.id}/lock.json"
      }.to change {
        room.reload.locked?
      }.from(false).to(true)

      expect(response.status).to eq(200)
      expect(response.body).to be_blank
    end

    it "pauses transcripts" do
      pending
    end
  end

  describe "POST /room/:id/unlock" do
    let!(:room) { create(:room, :locked) }

    it "unlocks the room" do
      expect {
        post "/room/#{room.id}/unlock.json"
      }.to change {
        room.reload.locked?
      }.from(true).to(false)

      expect(response.status).to eq(200)
      expect(response.body).to be_blank
    end

    it "resumes transcripts" do
      pending
    end
  end
end
