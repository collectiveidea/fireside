require "spec_helper"

describe "Message Requests" do
  with_formats(:json, :xml) do
    describe "GET /room/:room_id/recent" do
      let!(:room) { create(:room) }

      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          authenticate(user.api_auth_token)
        end

        it "lists messages old to new" do
          old_message = create(:text_message, room: room, created_at: 1.day.ago)
          new_message = create(:text_message, room: room, created_at: 1.minute.ago)
          create(:text_message)

          get "/room/#{room.id}/recent"

          expect(response.status).to eq(200)
          expect(response.content).to eq(
            "messages" => [
              {
                "body" => old_message.body,
                "created_at" => old_message.created_at,
                "id" => old_message.id,
                "room_id" => old_message.room_id,
                "starred" => old_message.starred?,
                "type" => old_message.type,
                "user_id" => old_message.user_id
              },
              {
                "body" => new_message.body,
                "created_at" => new_message.created_at,
                "id" => new_message.id,
                "room_id" => new_message.room_id,
                "starred" => new_message.starred?,
                "type" => new_message.type,
                "user_id" => new_message.user_id
              }
            ]
          )
        end

        it "limits to 25 messages by default" do
          create_list(:text_message, 26, room: room)

          get "/room/#{room.id}/recent"

          expect(response.status).to eq(200)
          expect(response.content.to_hash["messages"]).to have(25).messages
        end

        it "limits to 25 messages by default" do
          create_list(:text_message, 11, room: room)

          get "/room/#{room.id}/recent?limit=10"

          expect(response.status).to eq(200)
          expect(response.content.to_hash["messages"]).to have(10).messages
        end

        it "shows expanded sound messages" do
          message = create(:sound_message, room: room)

          get "/room/#{room.id}/recent"

          expect(response.status).to eq(200)
          expect(response.content).to eq(
            "messages" => [
              {
                "body" => message.body,
                "created_at" => message.created_at,
                "description" => message.description,
                "id" => message.id,
                "room_id" => message.room_id,
                "starred" => message.starred?,
                "type" => message.type,
                "url" => message.url,
                "user_id" => message.user_id
              }
            ]
          )
        end

        it "shows expanded tweet messages" do
          message = create(:tweet_message, room: room)

          get "/room/#{room.id}/recent"

          expect(response.status).to eq(200)
          expect(response.content).to eq(
            "messages" => [
              {
                "body" => message.body,
                "created_at" => message.created_at,
                "id" => message.id,
                "room_id" => message.room_id,
                "starred" => message.starred?,
                "tweet" => message.metadata,
                "type" => message.type,
                "user_id" => message.user_id
              }
            ]
          )
        end
      end

      context "when unauthenticated" do
        it "requires authentication" do
          get "/room/#{room.id}/recent"

          expect(response.status).to eq(401)
        end
      end
    end

    describe "GET /room/:room_id/transcript" do
      let!(:room) { create(:room) }

      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          authenticate(user.api_auth_token)
        end

        it "lists messages old to new" do
          create(:text_message, room: room, created_at: 1.day.ago)
          old_message = create(:text_message, room: room, created_at: 2.minutes.ago)
          new_message = create(:text_message, room: room, created_at: 1.minute.ago)
          create(:text_message)

          get "/room/#{room.id}/transcript"

          expect(response.status).to eq(200)
          expect(response.content).to eq(
            "messages" => [
              {
                "body" => old_message.body,
                "created_at" => old_message.created_at,
                "id" => old_message.id,
                "room_id" => old_message.room_id,
                "starred" => old_message.starred?,
                "type" => old_message.type,
                "user_id" => old_message.user_id
              },
              {
                "body" => new_message.body,
                "created_at" => new_message.created_at,
                "id" => new_message.id,
                "room_id" => new_message.room_id,
                "starred" => new_message.starred?,
                "type" => new_message.type,
                "user_id" => new_message.user_id
              }
            ]
          )
        end

        it "shows expanded sound messages" do
          message = create(:sound_message, room: room)

          get "/room/#{room.id}/transcript"

          expect(response.status).to eq(200)
          expect(response.content).to eq(
            "messages" => [
              {
                "body" => message.body,
                "created_at" => message.created_at,
                "description" => message.description,
                "id" => message.id,
                "room_id" => message.room_id,
                "starred" => message.starred?,
                "type" => message.type,
                "url" => message.url,
                "user_id" => message.user_id
              }
            ]
          )
        end

        it "shows expanded tweet messages" do
          message = create(:tweet_message, room: room)

          get "/room/#{room.id}/transcript"

          expect(response.status).to eq(200)
          expect(response.content).to eq(
            "messages" => [
              {
                "body" => message.body,
                "created_at" => message.created_at,
                "id" => message.id,
                "room_id" => message.room_id,
                "starred" => message.starred?,
                "tweet" => message.metadata,
                "type" => message.type,
                "user_id" => message.user_id
              }
            ]
          )
        end
      end

      context "when unauthenticated" do
        it "requires authentication" do
          get "/room/#{room.id}/transcript"

          expect(response.status).to eq(401)
        end
      end
    end

    describe "GET /room/:room_id/transcript/:year/:month/:day" do
      let!(:room) { create(:room) }

      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          authenticate(user.api_auth_token)
        end

        it "lists messages old to new" do
          create(:text_message, room: room, created_at: Time.new(2014, 2, 9, 12, 0, 0))
          old_message = create(:text_message, room: room, created_at: Time.new(2014, 2, 10, 12, 0, 0))
          new_message = create(:text_message, room: room, created_at: Time.new(2014, 2, 10, 12, 0, 1))
          create(:text_message, room: room, created_at: Time.new(2014, 2, 11, 12, 0, 0))

          get "/room/#{room.id}/transcript/2014/02/10"

          expect(response.status).to eq(200)
          expect(response.content).to eq(
            "messages" => [
              {
                "body" => old_message.body,
                "created_at" => old_message.created_at,
                "id" => old_message.id,
                "room_id" => old_message.room_id,
                "starred" => old_message.starred?,
                "type" => old_message.type,
                "user_id" => old_message.user_id
              },
              {
                "body" => new_message.body,
                "created_at" => new_message.created_at,
                "id" => new_message.id,
                "room_id" => new_message.room_id,
                "starred" => new_message.starred?,
                "type" => new_message.type,
                "user_id" => new_message.user_id
              }
            ]
          )
        end

        it "shows expanded sound messages" do
          message = create(:sound_message, room: room, created_at: Time.new(2014, 2, 10, 12, 0, 0))

          get "/room/#{room.id}/transcript/2014/02/10"

          expect(response.status).to eq(200)
          expect(response.content).to eq(
            "messages" => [
              {
                "body" => message.body,
                "created_at" => message.created_at,
                "description" => message.description,
                "id" => message.id,
                "room_id" => message.room_id,
                "starred" => message.starred?,
                "type" => message.type,
                "url" => message.url,
                "user_id" => message.user_id
              }
            ]
          )
        end

        it "shows expanded tweet messages" do
          message = create(:tweet_message, room: room, created_at: Time.new(2014, 2, 10, 12, 0, 0))

          get "/room/#{room.id}/transcript/2014/02/10"

          expect(response.status).to eq(200)
          expect(response.content).to eq(
            "messages" => [
              {
                "body" => message.body,
                "created_at" => message.created_at,
                "id" => message.id,
                "room_id" => message.room_id,
                "starred" => message.starred?,
                "tweet" => message.metadata,
                "type" => message.type,
                "user_id" => message.user_id
              }
            ]
          )
        end

        it "accepts single-digit month and day" do
          create(:text_message, room: room, created_at: Time.new(2014, 2, 9, 12, 0, 0))

          get "/room/#{room.id}/transcript/2014/2/9"

          expect(response.status).to eq(200)
          expect(response.content.to_hash["messages"]).to have(1).message
        end
      end

      context "when unauthenticated" do
        it "requires authentication" do
          get "/room/#{room.id}/transcript/2014/02/10"

          expect(response.status).to eq(401)
        end
      end
    end

    describe "POST /room/:room_id/speak" do
      let!(:room) { create(:room) }

      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          authenticate(user.api_auth_token)
        end

        context "when successful" do
          context "when the room is unlocked" do
            it "creates a message" do
              expect {
                post "/room/#{room.id}/speak", "message" => { "body" => "Hello, world!" }
              }.to change {
                Message.count
              }.from(0).to(1)

              message = Message.last

              expect(message.body).to eq("Hello, world!")
              expect(message.user_id).to eq(user.id)
              expect(message.room_id).to eq(room.id)
              expect(message).not_to be_private

              expect(response.status).to eq(201)
              expect(response.content).to eq(
                "message" => {
                  "body" => message.body,
                  "created_at" => message.created_at,
                  "id" => message.id,
                  "room_id" => message.room_id,
                  "starred" => message.starred?,
                  "type" => message.type,
                  "user_id" => message.user_id
                }
              )
            end
          end

          context "when the room is locked" do
            let!(:room) { create(:room, :locked) }

            it "creates a private message" do
              expect {
                post "/room/#{room.id}/speak", "message" => { "body" => "Hello, world!" }
              }.to change {
                Message.count
              }.from(0).to(1)

              message = Message.last

              expect(message.body).to eq("Hello, world!")
              expect(message.user_id).to eq(user.id)
              expect(message.room_id).to eq(room.id)
              expect(message).to be_private

              expect(response.status).to eq(201)
              expect(response.content).to eq(
                "message" => {
                  "body" => message.body,
                  "created_at" => message.created_at,
                  "id" => message.id,
                  "room_id" => message.room_id,
                  "starred" => message.starred?,
                  "type" => message.type,
                  "user_id" => message.user_id
                }
              )
            end
          end
        end

        context "when no body is provided" do
          it "is a bad request" do
            expect {
              post "/room/#{room.id}/speak", "message" => {}
            }.not_to change {
              Message.count
            }

            expect(response.status).to eq(400)
            expect(response.body).to be_blank
          end
        end

        context "when a blank body is given" do
          it "returns validation errors" do
            expect {
              post "/room/#{room.id}/speak", "message" => { "body" => " " }
            }.not_to change {
              Message.count
            }

            expect(response.status).to eq(422)
            expect(response.content).to be_present
          end
        end
      end

      context "when unauthenticated" do
        it "requires authentication" do
          expect {
            post "/room/#{room.id}/speak", "message" => { "body" => "Hello, world!" }
          }.not_to change {
            Message.count
          }

          expect(response.status).to eq(401)
        end
      end
    end

    describe "POST /messages/:id/star" do
      let!(:message) { create(:text_message) }

      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          authenticate(user.api_auth_token)
        end

        it "stars the message" do
          expect {
            post "/messages/#{message.id}/star"
          }.to change {
            message.reload.starred?
          }.from(false).to(true)

          expect(response.status).to eq(200)
          expect(response.body).to be_blank
        end
      end

      context "when unauthenticated" do
        it "requires authentication" do
          expect {
            post "/messages/#{message.id}/star"
          }.not_to change {
            message.reload.starred?
          }

          expect(response.status).to eq(401)
        end
      end
    end

    describe "DELETE /messages/:id/star" do
      let!(:message) { create(:text_message, :starred) }

      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          authenticate(user.api_auth_token)
        end

        it "unstars the message" do
          expect {
            delete "/messages/#{message.id}/star"
          }.to change {
            message.reload.starred?
          }.from(true).to(false)

          expect(response.status).to eq(200)
          expect(response.body).to be_blank
        end
      end

      context "when unauthenticated" do
        it "requires authentication" do
          expect {
            post "/messages/#{message.id}/star"
          }.not_to change {
            message.reload.starred?
          }

          expect(response.status).to eq(401)
        end
      end
    end
  end
end
