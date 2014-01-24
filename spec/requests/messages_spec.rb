require "spec_helper"

describe "Message Requests" do
  describe "GET /room/:room_id/recent" do
    let!(:room) { create(:room) }
    let!(:old_message) { create(:message, room: room, created_at: 2.minutes.ago) }
    let!(:new_message) { create(:message, room: room, created_at: 1.minute.ago) }
    let!(:other_message) { create(:message) }

    it "lists messages old to new" do
      get "/room/#{room.id}/recent.json"

      expect(response.status).to eq(200)
      expect(response.json).to eq(
        "messages" => [
          {
            "body" => old_message.body,
            "created_at" => old_message.created_at.as_json,
            "id" => old_message.id,
            "room_id" => old_message.room_id
          },
          {
            "body" => new_message.body,
            "created_at" => new_message.created_at.as_json,
            "id" => new_message.id,
            "room_id" => new_message.room_id
          }
        ]
      )
    end
  end

  describe "POST /room/:room_id/speak" do
    let!(:room) { create(:room) }

    it "creates a message" do
      expect {
        post_json "/room/#{room.id}/speak.json", %({"body":"Hello, world!"})
      }.to change {
        Message.count
      }.from(0).to(1)

      message = Message.last

      expect(message.body).to eq("Hello, world!")
      expect(message.room_id).to eq(room.id)

      expect(response.status).to eq(201)
      expect(response.json).to eq(
        "message" => {
          "body" => message.body,
          "created_at" => message.created_at.as_json,
          "id" => message.id,
          "room_id" => message.room_id
        }
      )
    end
  end

  describe "POST /messages/:id/star" do
    let!(:message) { create(:message) }

    it "stars the message" do
      expect {
        post "/messages/#{message.id}/star.json"
      }.to change {
        message.reload.starred?
      }.from(false).to(true)

      expect(response.status).to eq(200)
      expect(response.body).to be_blank
    end
  end

  describe "DELETE /messages/:id/star" do
    let!(:message) { create(:message, :starred) }

    it "unstars the message" do
      expect {
        delete "/messages/#{message.id}/star.json"
      }.to change {
        message.reload.starred?
      }.from(true).to(false)

      expect(response.status).to eq(200)
      expect(response.body).to be_blank
    end
  end
end
