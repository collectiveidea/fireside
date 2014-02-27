require "spec_helper"

describe "Upload Requests" do
  with_formats(:json, :xml) do
    describe "GET /room/:room_id/uploads" do
      context "when authenticated" do
        before do
          authenticate(user.api_auth_token)
        end

        context "as an admin" do
          let!(:user) { create(:user, :admin) }
          let!(:room) { create(:room, :locked) }

          it "lists public uploads old to new" do
            old_upload = create(:upload, room: room)
            new_upload = create(:upload, room: room)
            create(:upload, :private, room: room)
            create(:upload)

            get "/room/#{room.id}/uploads"

            expect(response.status).to eq(200)
            expect(response.content).to eq(
              "uploads" => [
                {
                  "byte_size" => old_upload.byte_size,
                  "content_type" => old_upload.content_type,
                  "created_at" => old_upload.created_at,
                  "full_url" => old_upload.full_url,
                  "id" => old_upload.id,
                  "name" => old_upload.name,
                  "room_id" => old_upload.room_id,
                  "user_id" => old_upload.user_id
                },
                {
                  "byte_size" => new_upload.byte_size,
                  "content_type" => new_upload.content_type,
                  "created_at" => new_upload.created_at,
                  "full_url" => new_upload.full_url,
                  "id" => new_upload.id,
                  "name" => new_upload.name,
                  "room_id" => new_upload.room_id,
                  "user_id" => new_upload.user_id
                }
              ]
            )
          end

          it "limits to 5 uploads" do
            create_list(:upload, 6, room: room)

            get "/room/#{room.id}/uploads"

            expect(response.status).to eq(200)
            expect(response.content.to_hash["uploads"]).to have(5).uploads
          end
        end

        context "as a member" do
          let!(:user) { create(:user) }

          context "when the room is locked" do
            let!(:room) { create(:room, :locked) }

            context "when the user is in the room" do
              before do
                room.users << user
              end

              it "lists uploads old to new" do
                create(:upload, room: room)
                create(:upload, room: room)
                create(:upload)

                get "/room/#{room.id}/uploads"

                expect(response.status).to eq(200)
                expect(response.content.to_hash["uploads"]).to have(2).uploads
              end
            end

            context "when the user is not in the room" do
              it "denies access" do
                get "/room/#{room.id}/uploads"

                expect(response.status).to eq(423)
                expect(response.body).to be_blank
              end
            end
          end

          context "when the room is unlocked" do
            let!(:room) { create(:room, :unlocked) }

            it "lists uploads" do
              create(:upload, room: room)
              create(:upload, room: room)
              create(:upload)

              get "/room/#{room.id}/uploads"

              expect(response.status).to eq(200)
              expect(response.content.to_hash["uploads"]).to have(2).uploads
            end
          end
        end
      end

      context "when unauthenticated" do
        let!(:room) { create(:room) }

        it "requires authentication" do
          get "/room/#{room.id}/uploads"

          expect(response.status).to eq(401)
        end
      end
    end

    describe "GET /room/:room_id/messages/:message_id/upload" do
      let!(:message) { create(:upload_message, room: room) }
      let!(:upload) { create(:upload, :private, room: room, message: message) }

      context "when authenticated" do
        before do
          authenticate(user.api_auth_token)
        end

        context "as an admin" do
          let!(:user) { create(:user, :admin) }
          let!(:room) { create(:room, :locked) }

          it "shows the upload" do
            get "/room/#{room.id}/messages/#{message.id}/upload"

            expect(response.status).to eq(200)
            expect(response.content).to eq(
              "upload" => {
                "byte_size" => upload.byte_size,
                "content_type" => upload.content_type,
                "created_at" => upload.created_at,
                "full_url" => upload.full_url,
                "id" => upload.id,
                "name" => upload.name,
                "room_id" => upload.room_id,
                "user_id" => upload.user_id
              }
            )
          end

          context "after the original message has been deleted" do
            before do
              message.destroy!
            end

            it "shows the upload" do
              get "/room/#{room.id}/messages/#{message.id}/upload"

              expect(response.status).to eq(200)
              expect(response.content.to_hash).to have_key("upload")
            end
          end
        end

        context "as a member" do
          let!(:user) { create(:user) }

          context "when the room is locked" do
            let!(:room) { create(:room, :locked) }

            context "when the user is in the room" do
              before do
                room.users << user
              end

              it "shows the upload" do
                get "/room/#{room.id}/messages/#{message.id}/upload"

                expect(response.status).to eq(200)
                expect(response.content.to_hash).to have_key("upload")
              end
            end

            context "when the user is not in the room" do
              it "denies access" do
                get "/room/#{room.id}/messages/#{message.id}/upload"

                expect(response.status).to eq(423)
                expect(response.body).to be_blank
              end
            end
          end

          context "when the room is unlocked" do
            let!(:room) { create(:room, :unlocked) }

            it "shows the upload" do
              get "/room/#{room.id}/messages/#{message.id}/upload"

              expect(response.status).to eq(200)
              expect(response.content.to_hash).to have_key("upload")
            end
          end
        end
      end

      context "when unauthenticated" do
        let!(:room) { create(:room) }

        it "requires authentication" do
          get "/room/#{room.id}/messages/#{message.id}/upload"

          expect(response.status).to eq(401)
        end
      end
    end

    describe "POST /room/:room_id/uploads" do
      let(:file) {
        path = Rails.root.join("spec/support/campfire.gif")
        Rack::Test::UploadedFile.new(path, "image/gif")
      }

      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          authenticate(user.api_auth_token)
        end

        context "when given a file" do
          let(:params) { { upload: file } }

          context "when the room is locked" do
            let!(:room) { create(:room, :locked) }

            it "creates an upload" do
              expect {
                post "/room/#{room.id}/uploads", params, "Content-Type" => "multipart/form-data"
              }.to change {
                Upload.count
              }.from(0).to(1)

              upload = Upload.last

              expect(upload.user_id).to eq(user.id)
              expect(upload.room_id).to eq(room.id)
              expect(upload.byte_size).to eq(931562)
              expect(upload.content_type).to eq("image/gif")
              expect(upload.name).to eq("campfire.gif")
              expect(upload).to be_private

              expect(response.status).to eq(201)
              expect(response.content).to eq(
                "upload" => {
                  "byte_size" => upload.byte_size,
                  "content_type" => upload.content_type,
                  "created_at" => upload.created_at,
                  "full_url" => upload.full_url,
                  "id" => upload.id,
                  "name" => upload.name,
                  "room_id" => upload.room_id,
                  "user_id" => upload.user_id
                }
              )
            end

            it "posts an upload message" do
              expect {
                post "/room/#{room.id}/uploads", params, "Content-Type" => "multipart/form-data"
              }.to change {
                Message.count
              }.by(1)

              message = Message.last
              expect(message).to be_a(UploadMessage)
              expect(message.user_id).to eq(user.id)
              expect(message.room_id).to eq(room.id)
              expect(message).to be_private
            end
          end

          context "when the room is unlocked" do
            let!(:room) { create(:room, :unlocked) }

            it "creates an upload" do
              expect {
                post "/room/#{room.id}/uploads", params, "Content-Type" => "multipart/form-data"
              }.to change {
                Upload.count
              }.from(0).to(1)

              upload = Upload.last

              expect(upload.user_id).to eq(user.id)
              expect(upload.room_id).to eq(room.id)
              expect(upload.byte_size).to eq(931562)
              expect(upload.content_type).to eq("image/gif")
              expect(upload.name).to eq("campfire.gif")
              expect(upload).not_to be_private

              expect(response.status).to eq(201)
              expect(response.content).to eq(
                "upload" => {
                  "byte_size" => upload.byte_size,
                  "content_type" => upload.content_type,
                  "created_at" => upload.created_at,
                  "full_url" => upload.full_url,
                  "id" => upload.id,
                  "name" => upload.name,
                  "room_id" => upload.room_id,
                  "user_id" => upload.user_id
                }
              )
            end

            it "posts an upload message" do
              expect {
                post "/room/#{room.id}/uploads", params, "Content-Type" => "multipart/form-data"
              }.to change {
                Message.count
              }.by(1)

              message = Message.last
              expect(message).to be_a(UploadMessage)
              expect(message.user_id).to eq(user.id)
              expect(message.room_id).to eq(room.id)
              expect(message).not_to be_private
            end
          end
        end

        context "when given a value" do
          let!(:room) { create(:room) }
          let(:params) { { upload: "foo" } }

          it "doesn't create an upload" do
            expect {
              post "/room/#{room.id}/uploads", params, "Content-Type" => "multipart/form-data"
            }.not_to change {
              Upload.count
            }

            expect(response.status).to eq(422)
          end

          it "doesn't post an upload message" do
            expect {
              post "/room/#{room.id}/uploads", params, "Content-Type" => "multipart/form-data"
            }.not_to change {
              Message.count
            }
          end
        end

        context "when given nothing" do
          let!(:room) { create(:room) }
          let(:params) { {} }

          it "doesn't create an upload" do
            expect {
              post "/room/#{room.id}/uploads", params, "Content-Type" => "multipart/form-data"
            }.not_to change {
              Upload.count
            }

            expect(response.status).to eq(422)
          end

          it "doesn't post an upload message" do
            expect {
              post "/room/#{room.id}/uploads", params, "Content-Type" => "multipart/form-data"
            }.not_to change {
              Message.count
            }
          end
        end
      end

      context "when unauthenticated" do
        let!(:room) { create(:room) }

        it "requires authentication" do
          expect {
            post "/room/#{room.id}/uploads", { upload: file }, { "Content-Type" => "multipart/form-data" }
          }.not_to change {
            Upload.count
          }

          expect(response.status).to eq(401)
        end
      end
    end
  end
end
