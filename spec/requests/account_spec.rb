require "spec_helper"

describe "Account Requests" do
  with_formats(:json, :xml) do
    describe "GET /account" do
      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          @original_host = ENV["HOST"]
          @original_time_zone = ENV["TIME_ZONE"]

          ENV["HOST"] = "foobar.baz"
          ENV["TIME_ZONE"] = "Central Time (US & Canada)"

          authenticate(user.api_auth_token)
        end

        after do
          ENV["HOST"] = @original_host
          ENV["TIME_ZONE"] = @original_time_zone
        end

        it "returns limited application configuration" do
          get "/account"

          timestamp = Time.utc(2014, 1, 23, 17, 23, 55).in_time_zone
          expect(response.status).to eq(200)
          expect(response.content).to eq(
            "account" => {
              "created_at" => timestamp,
              "id" => 1,
              "name" => "foobar.baz",
              "owner_id" => nil,
              "plan" => nil,
              "subdomain" => nil,
              "storage" => 0,
              "time_zone" => "America/Chicago",
              "updated_at" => timestamp
            }
          )
        end
      end

      context "when unauthenticated" do
        it "requires authentication" do
          get "/account"

          expect(response.status).to eq(401)
        end
      end
    end
  end
end
