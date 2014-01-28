require "spec_helper"

describe "Upload Requests" do
  describe "POST /room/:room_id/uploads" do
    let!(:room) { create(:room) }

    context "when authenticated" do
      let!(:user) { create(:user) }

      before do
        authenticate(user.api_auth_token)
      end

      it "creates an upload" do
        default_env["Content-Type"] = "multipart/form-data"
        path = Rails.root.join("spec/support/campfire.gif")
        upload = Rack::Test::UploadedFile.new(path, "image/gif")

        expect {
          post "/room/#{room.id}/uploads.json", upload: upload
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
        expect(response.json).to eq(
          "upload" => {
            "byte_size" => upload.byte_size,
            "content_type" => upload.content_type,
            "created_at" => upload.created_at.as_json,
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
        expect {
          post "/room/#{room.id}/uploads"
        }.not_to change {
          Upload.count
        }

        expect(response.status).to eq(401)
      end
    end
  end
end
