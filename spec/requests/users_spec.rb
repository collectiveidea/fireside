require "spec_helper"

describe "User Requests" do
  using_json_and_xml do
    describe "GET /users/:id" do
      let!(:user) { create(:user, :admin) }

      context "when authenticated" do
        let!(:current_user) { create(:user) }

        before do
          authenticate(current_user.api_auth_token)
        end

        it "shows the user" do
          get "/users/#{user.id}"

          expect(response.status).to eq(200)
          expect(response.content).to eq(
            "user" => {
              "admin" => user.admin?,
              "avatar_url" => user.avatar_url,
              "created_at" => user.created_at,
              "email_address" => user.email,
              "id" => user.id,
              "name" => user.name
            }
          )
        end
      end

      context "when unauthenticated" do
        it "requires authentication" do
          get "/users/#{user.id}"

          expect(response.status).to eq(401)
        end
      end
    end

    describe "GET /users/me" do
      let!(:user) { create(:user, password: "secret") }

      context "when authenticated by API key" do
        before do
          authenticate(user.api_auth_token)
        end

        it "shows the current user" do
          get "/users/me"

          expect(response.status).to eq(200)
          expect(response.content).to eq(
            "user" => {
              "admin" => user.admin?,
              "api_auth_token" => user.api_auth_token,
              "avatar_url" => user.avatar_url,
              "created_at" => user.created_at,
              "email_address" => user.email,
              "id" => user.id,
              "name" => user.name
            }
          )
        end
      end

      context "when authenticated by email and password" do
        before do
          authenticate(user.email, "secret")
        end

        it "shows the current user" do
          get "/users/me"

          expect(response.status).to eq(200)
          expect(response.content).to eq(
            "user" => {
              "admin" => user.admin?,
              "api_auth_token" => user.api_auth_token,
              "avatar_url" => user.avatar_url,
              "created_at" => user.created_at,
              "email_address" => user.email,
              "id" => user.id,
              "name" => user.name
            }
          )
        end
      end

      context "when unauthenticated" do
        it "requires authentication" do
          get "/users/me"

          expect(response.status).to eq(401)
        end
      end
    end
  end
end
