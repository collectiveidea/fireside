require "spec_helper"

describe "Message Requests" do
  describe "GET /messages/:id" do
    let!(:message) { create(:message) }

    it "shows the message" do
      get "/messages/#{message.id}"

      expect(response.status).to eq(200)
      expect(response.json).to eq(
        message: {
          body: message.body,
          created_at: message.created_at.as_json
        }
      )
    end
  end
end
