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
            "created_at" => old_message.created_at.as_json
          },
          {
            "body" => new_message.body,
            "created_at" => new_message.created_at.as_json
          }
        ]
      )
    end
  end

  describe "GET /messages/:id" do
    let!(:message) { create(:message) }

    it "shows the message" do
      get "/messages/#{message.id}"

      expect(response.status).to eq(200)
      expect(response.json).to eq(
        "message" => {
          "body" => message.body,
          "created_at" => message.created_at.as_json
        }
      )
    end
  end
end
