require "spec_helper"

describe "Upload Requests" do
  with_formats(:json, :xml) do
    describe "POST /room/:room_id/uploads" do
      let!(:room) { create(:room) }
      let!(:upload) {
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
            post "/room/#{room.id}/uploads", { upload: upload }, { "Content-Type" => "multipart/form-data" }
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
            post "/room/#{room.id}/uploads", { upload: upload }, { "Content-Type" => "multipart/form-data" }
          }.not_to change {
            Upload.count
          }

          expect(response.status).to eq(401)
        end
      end
    end
  end
end
