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
      let!(:other_user) { create(:user) }

      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          room.users << other_user
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
              "updated_at" => room.updated_at,
              "users" => [
                {
                  "admin" => other_user.admin?,
                  "avatar_url" => other_user.avatar_url,
                  "created_at" => other_user.created_at,
                  "email_address" => other_user.email,
                  "id" => other_user.id,
                  "name" => other_user.name,
                  "type" => "Member"
                }
              ]
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

            it "doesn't add a user to the room" do
              expect {
                post "/room/#{room.id}/join"
              }.not_to change {
                room.users.count
              }

              expect(response.status).to eq(200)
              expect(response.body).to be_blank
            end

            it "doesn't post an enter message" do
              expect {
                post "/room/#{room.id}/join"
              }.not_to change {
                Message.count
              }
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

            it "posts an enter message" do
              expect {
                post "/room/#{room.id}/join"
              }.to change {
                Message.count
              }.by(1)

              message = Message.last
              expect(message).to be_a(EnterMessage)
              expect(message.user_id).to eq(user.id)
              expect(message.room_id).to eq(room.id)
              expect(message).not_to be_private
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

            it "posts an enter message" do
              expect {
                post "/room/#{room.id}/join"
              }.to change {
                Message.count
              }.by(1)

              message = Message.last
              expect(message).to be_a(EnterMessage)
              expect(message.user_id).to eq(user.id)
              expect(message.room_id).to eq(room.id)
              expect(message).to be_private
            end
          end
        end

        context "as a member" do
          let!(:user) { create(:user) }

          context "when the user is in the room" do
            before do
              user.rooms << room
            end

            it "doesn't add a user to the room" do
              expect {
                post "/room/#{room.id}/join"
              }.not_to change {
                room.users.count
              }

              expect(response.status).to eq(200)
              expect(response.body).to be_blank
            end

            it "doesn't post an enter message" do
              expect {
                post "/room/#{room.id}/join"
              }.not_to change {
                Message.count
              }
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

            it "posts an enter message" do
              expect {
                post "/room/#{room.id}/join"
              }.to change {
                Message.count
              }.by(1)

              message = Message.last
              expect(message).to be_a(EnterMessage)
              expect(message.user_id).to eq(user.id)
              expect(message.room_id).to eq(room.id)
              expect(message).not_to be_private
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

            it "doesn't post an enter message" do
              expect {
                post "/room/#{room.id}/join"
              }.not_to change {
                Message.count
              }
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

          it "posts a leave message" do
            expect {
              post "/room/#{room.id}/leave"
            }.to change {
              Message.count
            }.by(1)

            message = Message.last
            expect(message).to be_a(LeaveMessage)
            expect(message.user_id).to eq(user.id)
            expect(message.room_id).to eq(room.id)
            expect(message).not_to be_private
          end
        end

        context "when the user is not in the room" do
          it "doesn't remove a user from the room" do
            expect {
              post "/room/#{room.id}/leave"
            }.not_to change {
              room.users.count
            }

            expect(response.status).to eq(200)
            expect(response.body).to be_blank
          end

          it "doesn't post a leave message" do
            expect {
              post "/room/#{room.id}/leave"
            }.not_to change {
              Message.count
            }
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
      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          authenticate(user.api_auth_token)
        end

        context "when unlocked" do
          let!(:room) { create(:room, :unlocked) }

          it "locks the room" do
            expect {
              post "/room/#{room.id}/lock"
            }.to change {
              room.reload.locked?
            }.from(false).to(true)

            expect(response.status).to eq(200)
            expect(response.body).to be_blank
          end

          it "posts a lock message" do
            expect {
              post "/room/#{room.id}/lock"
            }.to change {
              Message.count
            }.by(1)

            message = Message.last
            expect(message).to be_a(LockMessage)
            expect(message.user_id).to eq(user.id)
            expect(message.room_id).to eq(room.id)
            expect(message).not_to be_private
          end
        end

        context "when locked" do
          let!(:room) { create(:room, :locked) }

          it "keeps the room locked" do
            expect {
              post "/room/#{room.id}/lock"
            }.not_to change {
              room.reload.locked?
            }

            expect(response.status).to eq(200)
            expect(response.body).to be_blank
          end

          it "doesn't post a lock message" do
            expect {
              post "/room/#{room.id}/lock"
            }.not_to change {
              Message.count
            }
          end
        end
      end

      context "when unauthenticated" do
        let!(:room) { create(:room, :unlocked) }

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
          message_1 = create(:text_message, room: room)
          message_2 = create(:lock_message, room: room)
          message_3 = create(:text_message, :private, room: room)
          message_4 = create(:text_message, :private, room: room)

          post "/room/#{room.id}/unlock"

          messages = room.messages
          expect(messages).to include(message_1, message_2)
          expect(messages).not_to include(message_3, message_4)
        end

        it "posts an unlock message" do
          post "/room/#{room.id}/unlock"

          message = Message.last
          expect(message).to be_a(UnlockMessage)
          expect(message.user_id).to eq(user.id)
          expect(message.room_id).to eq(room.id)
          expect(message).not_to be_private
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
