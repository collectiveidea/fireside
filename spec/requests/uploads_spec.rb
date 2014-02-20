require "spec_helper"

describe "Upload Requests" do
  with_formats(:json, :xml) do
    describe "GET /room/:room_id/uploads" do
      let!(:room) { create(:room) }

      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          authenticate(user.api_auth_token)
        end

        it "lists uploads old to new" do
          old_upload = create(:upload, room: room)
          new_upload = create(:upload, room: room)
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

      context "when unauthenticated" do
        it "requires authentication" do
          get "/room/#{room.id}/uploads"

          expect(response.status).to eq(401)
        end
      end
    end

    describe "GET /room/:room_id/messages/:message_id/upload" do
      let!(:room) { create(:room) }
      let!(:upload) { create(:upload, room: room) }
      let!(:message) { create(:upload_message, room: room, upload: upload) }

      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          authenticate(user.api_auth_token)
        end

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
      end

      context "when unauthenticated" do
        it "requires authentication" do
          get "/room/#{room.id}/messages/#{message.id}/upload"

          expect(response.status).to eq(401)
        end
      end
    end

    describe "POST /room/:room_id/uploads" do
      let!(:room) { create(:room) }
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
          end
        end

        context "when given a value" do
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
