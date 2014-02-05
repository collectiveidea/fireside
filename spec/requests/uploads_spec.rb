require "spec_helper"

describe "Upload Requests" do
  def upload_full_url(upload)
    "#{https? ? "https" : "http"}://#{host}#{upload.file.url}"
  end

  with_formats(:json, :xml) do
    describe "GET /room/:room_id/uploads" do
      let!(:room) { create(:room) }
      let!(:old_upload) { create(:upload, room: room) }
      let!(:new_upload) { create(:upload, room: room) }
      let!(:other_upload) { create(:upload) }

      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          authenticate(user.api_auth_token)
        end

        it "lists uploads old to new" do
          get "/room/#{room.id}/uploads"

          expect(response.status).to eq(200)
          expect(response.content).to eq(
            "uploads" => [
              {
                "byte_size" => old_upload.byte_size,
                "content_type" => old_upload.content_type,
                "created_at" => old_upload.created_at,
                "full_url" => upload_full_url(old_upload),
                "id" => old_upload.id,
                "name" => old_upload.name,
                "room_id" => old_upload.room_id,
                "user_id" => old_upload.user_id
              },
              {
                "byte_size" => new_upload.byte_size,
                "content_type" => new_upload.content_type,
                "created_at" => new_upload.created_at,
                "full_url" => upload_full_url(new_upload),
                "id" => new_upload.id,
                "name" => new_upload.name,
                "room_id" => new_upload.room_id,
                "user_id" => new_upload.user_id
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

    describe "POST /room/:room_id/uploads" do
      let!(:room) { create(:room) }
      let!(:file) {
        path = Rails.root.join("spec/support/campfire.gif")
        Rack::Test::UploadedFile.new(path, "image/gif")
      }

      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          authenticate(user.api_auth_token)
        end

        it "creates an upload" do
          expect {
            post "/room/#{room.id}/uploads", { upload: file }, { "Content-Type" => "multipart/form-data" }
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
              "full_url" => upload_full_url(upload),
              "id" => upload.id,
              "name" => upload.name,
              "room_id" => upload.room_id,
              "user_id" => upload.user_id
            }
          )
        end

        it "posts an upload message" do
          expect {
            post "/room/#{room.id}/uploads", { upload: file }, { "Content-Type" => "multipart/form-data" }
          }.to change {
            Message.count
          }.by(1)

          message = Message.last
          expect(message).to be_a(UploadMessage)
          expect(message.user_id).to eq(user.id)
          expect(message.room_id).to eq(room.id)
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
