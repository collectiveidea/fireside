require "spec_helper"

describe "Room Requests" do
  with_formats(:json, :xml) do
    describe "GET /rooms" do
      let!(:room_1) { create(:room, created_at: 2.days.ago) }
      let!(:room_2) { create(:room, :locked, created_at: 1.day.ago) }

      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          authenticate(user.api_auth_token)
        end

        it "lists all rooms" do
          get "/rooms"

          expect(response.status).to eq(200)
          expect(response.content).to eq(
            "rooms" => [
              {
                "created_at" => room_1.created_at,
                "id" => room_1.id,
                "locked" => room_1.locked?,
                "membership_limit" => room_1.membership_limit,
                "name" => room_1.name,
                "topic" => room_1.topic,
                "updated_at" => room_1.updated_at
              },
              {
                "created_at" => room_2.created_at,
                "id" => room_2.id,
                "locked" => room_2.locked?,
                "membership_limit" => room_2.membership_limit,
                "name" => room_2.name,
                "topic" => room_2.topic,
                "updated_at" => room_2.updated_at,
              }
            ]
          )
        end
      end

      context "when unauthenticated" do
        it "requires authentication" do
          get "/rooms"

          expect(response.status).to eq(401)
        end
      end
    end

    describe "GET /presence" do
      let!(:room_1) { create(:room, created_at: 3.days.ago) }
      let!(:room_2) { create(:room, created_at: 2.days.ago) }
      let!(:room_3) { create(:room, created_at: 1.day.ago) }

      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          authenticate(user.api_auth_token)
        end

        it "lists the current user's rooms" do
          create(:presence, user: user, room: room_1)
          create(:presence, user: user, room: room_3)

          get "/presence"

          expect(response.status).to eq(200)
          expect(response.content).to eq(
            "rooms" => [
              {
                "created_at" => room_1.created_at,
                "id" => room_1.id,
                "locked" => room_1.locked?,
                "membership_limit" => room_1.membership_limit,
                "name" => room_1.name,
                "topic" => room_1.topic,
                "updated_at" => room_1.updated_at
              },
              {
                "created_at" => room_3.created_at,
                "id" => room_3.id,
                "locked" => room_3.locked?,
                "membership_limit" => room_3.membership_limit,
                "name" => room_3.name,
                "topic" => room_3.topic,
                "updated_at" => room_3.updated_at
              }
            ]
          )
        end
      end

      context "when unauthenticated" do
        it "requires authentication" do
          get "/rooms"

          expect(response.status).to eq(401)
        end
      end
    end

    describe "GET /room/:id" do
      let!(:room) { create(:room, :with_guest_access, :locked) }

      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          authenticate(user.api_auth_token)
        end

        it "shows the room" do
          get "/room/#{room.id}"

          expect(response.status).to eq(200)
          expect(response.content).to eq(
            "room" => {
              "active_token_value" => room.active_token_value,
              "created_at" => room.created_at,
              "full" => room.full?,
              "id" => room.id,
              "locked" => room.locked?,
              "membership_limit" => room.membership_limit,
              "name" => room.name,
              "open_to_guests" => room.open_to_guests?,
              "topic" => room.topic,
              "updated_at" => room.updated_at
            }
          )
        end
      end

      context "when unauthenticated" do
        it "requires authentication" do
          get "/room/#{room.id}"

          expect(response.status).to eq(401)
        end
      end
    end

    describe "PUT /room/:id" do
      let!(:room) { create(:room, topic: "Hello!") }

      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          authenticate(user.api_auth_token)
        end

        it "updates the room" do
          expect {
            put "/room/#{room.id}", "room" => { "topic" => "Goodbye." }
          }.to change {
            room.reload.topic
          }.from("Hello!").to("Goodbye.")

          expect(response.status).to eq(200)
          expect(response.body).to be_blank
        end
      end

      context "when unauthenticated" do
        it "requires authentication" do
          expect {
            put "/room/#{room.id}", "room" => { "topic" => "Goodbye." }
          }.not_to change {
            room.reload.topic
          }

          expect(response.status).to eq(401)
        end
      end
    end

    describe "POST /room/:id/join" do
      let!(:room) { create(:room) }

      context "when authenticated" do
        before do
          authenticate(user.api_auth_token)
        end

        context "as an admin" do
          let!(:user) { create(:user, :admin) }

          context "when the user is in the room" do
            before do
              user.rooms << room
            end

            it "does nothing" do
              expect {
                post "/room/#{room.id}/join"
              }.not_to change {
                room.users.count
              }

              expect(response.status).to eq(200)
              expect(response.body).to be_blank
            end
          end

          context "when the user is not in the room" do
            it "adds the current user to the room" do
              expect {
                post "/room/#{room.id}/join"
              }.to change {
                room.users.count
              }.from(0).to(1)

              expect(response.status).to eq(200)
              expect(response.body).to be_blank
            end
          end

          context "when the room is locked" do
            let!(:room) { create(:room, :locked) }

            it "allows access to the room" do
              expect {
                post "/room/#{room.id}/join"
              }.to change {
                room.users.count
              }.from(0).to(1)

              expect(response.status).to eq(200)
              expect(response.body).to be_blank
            end
          end
        end

        context "as a member" do
          let!(:user) { create(:user) }

          context "when the user is in the room" do
            before do
              user.rooms << room
            end

            it "does nothing" do
              expect {
                post "/room/#{room.id}/join"
              }.not_to change {
                room.users.count
              }

              expect(response.status).to eq(200)
              expect(response.body).to be_blank
            end
          end

          context "when the user is not in the room" do
            it "adds the current user to the room" do
              expect {
                post "/room/#{room.id}/join"
              }.to change {
                room.users.count
              }.from(0).to(1)

              expect(response.status).to eq(200)
              expect(response.body).to be_blank
            end
          end

          context "when the room is locked" do
            let!(:room) { create(:room, :locked) }

            it "denies access to the room" do
              expect {
                post "/room/#{room.id}/join"
              }.not_to change {
                room.users.count
              }

              expect(response.status).to eq(423)
              expect(response.body).to be_blank
            end
          end
        end
      end

      context "when unauthenticated" do
        it "requires authentication" do
          expect {
            post "/room/#{room.id}/join"
          }.not_to change {
            room.users.count
          }

          expect(response.status).to eq(401)
        end
      end
    end

    describe "POST /room/:id/leave" do
      let!(:room) { create(:room) }

      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          authenticate(user.api_auth_token)
        end

        context "when the user is in the room" do
          before do
            user.rooms << room
          end

          it "removes the current user from the room" do
            expect {
              post "/room/#{room.id}/leave"
            }.to change {
              room.users.count
            }.from(1).to(0)

            expect(response.status).to eq(200)
            expect(response.body).to be_blank
          end
        end

        context "when the user is not in the room" do
          it "does nothing" do
            expect {
              post "/room/#{room.id}/leave"
            }.not_to change {
              room.users.count
            }

            expect(response.status).to eq(200)
            expect(response.body).to be_blank
          end
        end
      end

      context "when unauthenticated" do
        it "requires authentication" do
          expect {
            post "/room/#{room.id}/leave"
          }.not_to change {
            room.users.count
          }

          expect(response.status).to eq(401)
        end
      end
    end

    describe "POST /room/:id/lock" do
      let!(:room) { create(:room) }

      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          authenticate(user.api_auth_token)
        end

        it "locks the room" do
          expect {
            post "/room/#{room.id}/lock"
          }.to change {
            room.reload.locked?
          }.from(false).to(true)

          expect(response.status).to eq(200)
          expect(response.body).to be_blank
        end
      end

      context "when unauthenticated" do
        it "requires authentication" do
          expect {
            post "/room/#{room.id}/lock"
          }.not_to change {
            room.reload.locked?
          }

          expect(response.status).to eq(401)
        end
      end
    end

    describe "POST /room/:id/unlock" do
      let!(:room) { create(:room, :locked) }

      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          authenticate(user.api_auth_token)
        end

        it "unlocks the room" do
          expect {
            post "/room/#{room.id}/unlock"
          }.to change {
            room.reload.locked?
          }.from(true).to(false)

          expect(response.status).to eq(200)
          expect(response.body).to be_blank
        end

        it "deletes private messsages" do
          message_1 = create(:message, room: room)
          message_2 = create(:message, room: room)
          create(:message, :private, room: room)
          create(:message, :private, room: room)

          expect {
            post "/room/#{room.id}/unlock"
          }.to change {
            room.messages.count
          }.from(4).to(2)

          expect(room.messages).to match_array([message_1, message_2])
        end
      end

      context "when unauthenticated" do
        it "requires authentication" do
          expect {
            post "/room/#{room.id}/unlock"
          }.not_to change {
            room.reload.locked?
          }

          expect(response.status).to eq(401)
        end
      end
    end
  end
end
