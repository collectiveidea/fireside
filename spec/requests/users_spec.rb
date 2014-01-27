require "spec_helper"

describe "User Requests" do
  describe "GET /users/:id" do
    let!(:user) { create(:user, :admin) }

    context "when authenticated" do
      let!(:current_user) { create(:user) }

      before do
        authenticate(current_user.api_auth_token)
      end

      it "shows the user" do
        get "/users/#{user.id}.json"

        expect(response.status).to eq(200)
        expect(response.json).to eq(
          "user" => {
            "admin" => user.admin?,
            "avatar_url" => user.avatar_url,
            "created_at" => user.created_at.as_json,
            "email_address" => user.email,
            "id" => user.id,
            "name" => user.name
          }
        )
      end
    end

    context "when unauthenticated" do
      it "requires authentication" do
        get "/users/#{user.id}.json"

        expect(response.status).to eq(401)
      end
    end
  end

  describe "GET /users/me" do
    it "shows the current user" do
      pending
    end
  end
end
