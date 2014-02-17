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
        expect(message.body).to eq("tmyk")
        expect(message.metadata).to eq(
          "description" => ":sparkles: :star: The More You Know :sparkles: :star:"
        )
      end

      it "creates a text message for an invalid sound" do
        message = Message.post(user, room, body: "/play tlyk")

        expect(message.reload).to be_a(TextMessage)
      end

      it "creates a text message when requested for a valid sound" do
        message = Message.post(user, room, body: "/play tmyk", type: "TextMessage")

        expect(message.reload).to be_a(TextMessage)
      end

      context "with Twitter configured" do
        before do
          @original_twitter_consumer_key = ENV["TWITTER_CONSUMER_KEY"]
          @original_twitter_consumer_secret = ENV["TWITTER_CONSUMER_SECRET"]

          ENV["TWITTER_CONSUMER_KEY"] = "key"
          ENV["TWITTER_CONSUMER_SECRET"] = "secret"
        end

        after do
          ENV["TWITTER_CONSUMER_KEY"] = @original_twitter_consumer_key
          ENV["TWITTER_CONSUMER_SECRET"] = @original_twitter_consumer_secret
        end

        it "creates an expanded tweet message for a valid tweet URL" do
          tweet_id = 428306266306269184
          tweet_user_screen_name = "StayPuft"
          tweet_url = "http://twitter.com/#{tweet_user_screen_name}/status/#{tweet_id}"
          tweet_text = "I'm so cold, I find myself looking at a campfire and wondering, what if..."
          tweet_user_profile_image_url = "http://pbs.twimg.com/profile_images/416421334973816832/MrIfbg-A_normal.jpeg"

          Twitter::REST::Client.any_instance.stub(:status).with(tweet_url) {
            Twitter::Tweet.new(
              id: tweet_id,
              text: tweet_text,
              user: {
                id: 458953226,
                profile_image_url_https: tweet_user_profile_image_url,
                screen_name: tweet_user_screen_name
              }
            )
          }

          message = Message.post(user, room, body: tweet_url)

          expect(message.reload).to be_a(TweetMessage)
          expect(message.body).to eq("#{tweet_text} -- @#{tweet_user_screen_name}, #{tweet_url}")
          expect(message.metadata).to eq(
            "author_avatar_url" => tweet_user_profile_image_url,
            "author_username" => tweet_user_screen_name,
            "message" => tweet_text,
            "id" => tweet_id
          )
        end

        it "creates a tweet message for an invalid tweet URL" do
          tweet_url = "http://twitter.com/StayPuft/status/428306266306269184"

          Twitter::REST::Client.any_instance.stub(:status).with(tweet_url) {
            raise Twitter::Error::NotFound
          }

          message = Message.post(user, room, body: tweet_url)

          expect(message.reload).to be_a(TweetMessage)
          expect(message.body).to eq(tweet_url)
          expect(message.metadata).to be_blank
        end

        it "creates a text message when requested for a valid tweet URL" do
          message = Message.post(user, room, body: "http://twitter.com/StayPuft/status/428306266306269184", type: "TextMessage")

          expect(message.reload).to be_a(TextMessage)
        end
      end

      context "without Twitter configured" do
        before do
          @original_twitter_consumer_key = ENV["TWITTER_CONSUMER_KEY"]
          @original_twitter_consumer_secret = ENV["TWITTER_CONSUMER_SECRET"]

          ENV["TWITTER_CONSUMER_KEY"] = nil
          ENV["TWITTER_CONSUMER_SECRET"] = nil
        end

        after do
          ENV["TWITTER_CONSUMER_KEY"] = @original_twitter_consumer_key
          ENV["TWITTER_CONSUMER_SECRET"] = @original_twitter_consumer_secret
        end

        it "creates a tweet message for a valid tweet URL" do
          tweet_url = "http://twitter.com/StayPuft/status/428306266306269184"

          message = Message.post(user, room, body: tweet_url)

          expect(message.reload).to be_a(TweetMessage)
          expect(message.body).to eq(tweet_url)
          expect(message.metadata).to be_blank
        end

        it "creates a tweet message for an invalid tweet URL" do
          tweet_url = "http://twitter.com/StayPuft/status/428306266306269184"

          Twitter::REST::Client.any_instance.stub(:status).with(tweet_url) {
            raise Twitter::Error::NotFound
          }

          message = Message.post(user, room, body: tweet_url)

          expect(message.reload).to be_a(TweetMessage)
          expect(message.body).to eq(tweet_url)
          expect(message.metadata).to be_blank
        end

        it "creates a text message when requested for a valid tweet URL" do
          message = Message.post(user, room, body: "http://twitter.com/StayPuft/status/428306266306269184", type: "TextMessage")

          expect(message.reload).to be_a(TextMessage)
        end
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
