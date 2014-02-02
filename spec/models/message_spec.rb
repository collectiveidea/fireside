require "spec_helper"

describe Message do
  describe ".old_to_new" do
    it "orders messages oldest to newest" do
      messages = [
        create(:message, created_at: 2.minutes.ago),
        create(:message, created_at: 3.minutes.ago),
        create(:message, created_at: 1.minute.ago)
      ]

      expect(Message.old_to_new).to eq(messages.sort_by(&:created_at))
    end
  end

  describe ".post" do
    let!(:user) { create(:user) }
    let!(:room) { create(:room) }

    context "when successful" do
      it "creates a message for the given user and room" do
        expect {
          Message.post(user, room, body: "Hello, world!")
        }.to change {
          Message.count
        }.from(0).to(1)

        message = Message.last

        expect(message.user_id).to eq(user.id)
        expect(message.room_id).to eq(room.id)
        expect(message.body).to eq("Hello, world!")
        expect(message).not_to be_private
      end

      it "creates a private message for a locked room" do
        room = create(:room, :locked)

        expect {
          Message.post(user, room, body: "Hello, world!")
        }.to change {
          Message.count
        }.from(0).to(1)

        message = Message.last

        expect(message.user_id).to eq(user.id)
        expect(message.room_id).to eq(room.id)
        expect(message.body).to eq("Hello, world!")
        expect(message).to be_private
      end

      it "returns the persisted message" do
        message = Message.post(user, room, body: "Hello, world!")

        expect(message).to be_a(Message)
        expect(message).to be_persisted
        expect(message.user_id).to eq(user.id)
        expect(message.room_id).to eq(room.id)
        expect(message.body).to eq("Hello, world!")
      end

      it "creates a paste message if requested" do
        message = Message.post(user, room, body: "Hello, world!", type: "PasteMessage")

        expect(message.reload).to be_a(PasteMessage)
      end

      it "creates a paste message by default with a newline" do
        message = Message.post(user, room, body: "Hello…\nworld!")

        expect(message.reload).to be_a(PasteMessage)
      end

      it "creates a text message if requested" do
        message = Message.post(user, room, body: "Hello…\nworld!", type: "TextMessage")

        expect(message.reload).to be_a(TextMessage)
      end

      it "creates a sound message by default for a valid sound" do
        message = Message.post(user, room, body: "/play tmyk")

        expect(message.reload).to be_a(SoundMessage)
      end

      it "creates a text message for an invalid sound" do
        message = Message.post(user, room, body: "/play tlyk")

        expect(message.reload).to be_a(TextMessage)
      end

      it "creates a text message when requested for a valid sound" do
        message = Message.post(user, room, body: "/play tmyk", type: "TextMessage")

        expect(message.reload).to be_a(TextMessage)
      end

      it "creates a tweet message for a valid tweet URL" do
        message = Message.post(user, room, body: "https://twitter.com/StayPuft/status/428306266306269184")

        expect(message.reload).to be_a(TweetMessage)
      end

      it "creates a text message when requested for a valid tweet URL" do
        message = Message.post(user, room, body: "https://twitter.com/StayPuft/status/428306266306269184", type: "TextMessage")

        expect(message.reload).to be_a(TextMessage)
      end

      it "creates a text message by default" do
        message = Message.post(user, room, body: "Hello, world!")

        expect(message.reload).to be_a(TextMessage)
      end

      it "converts other types to text messages" do
        message = Message.post(user, room, body: "Hello, world!", type: "UploadMessage")

        expect(message.reload).to be_a(TextMessage)
      end
    end

    context "when unsuccessful" do
      it "doesn't create a message" do
        expect {
          Message.post(user, room, {})
        }.not_to change {
          Message.count
        }
      end

      it "returns the new message" do
        message = Message.post(user, room, body: " ")

        expect(message).to be_a(Message)
        expect(message).not_to be_persisted
        expect(message.body).to eq(" ")
      end
    end
  end

  describe "#star" do
    it "sets starred to true and saves" do
      message = create(:message, starred: false)

      expect {
        message.star
      }.to change {
        message.reload.starred?
      }.from(false).to(true)
    end
  end

  describe "#unstar" do
    it "sets starred to false and saves" do
      message = create(:message, starred: true)

      expect {
        message.unstar
      }.to change {
        message.reload.starred?
      }.from(true).to(false)
    end
  end
end
