require "spec_helper"

describe "Message Requests" do
  describe "GET /messages" do
    let!(:old_message) { create(:message, created_at: 2.minutes.ago) }
    let!(:new_message) { create(:message, created_at: 1.minute.ago) }

    it "lists messages old to new" do
      get "/messages"

      expect(response.status).to eq(200)
      expect(response.json).to eq(
        "messages" => [
          {
            "body" => old_message.body,
            "created_at" => old_message.created_at.as_json,
            "id" => old_message.id
          },
          {
            "body" => new_message.body,
            "created_at" => new_message.created_at.as_json,
            "id" => new_message.id
          }
        ]
      )
    end
  end

  describe "POST /messages" do
    it "creates a message" do
      expect {
        post_json "/messages", %({"body":"Hello, world!"})
      }.to change {
        Message.count
      }.from(0).to(1)

      message = Message.last

      expect(response.status).to eq(201)
      expect(response.json).to eq(
        "message" => {
          "body" => message.body,
          "created_at" => message.created_at.as_json,
          "id" => message.id
        }
      )
    end
  end
end
