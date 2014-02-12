require "spec_helper"

describe "Search Requests" do
  with_formats(:json, :xml) do
    describe "GET /search/:q" do
      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          authenticate(user.api_auth_token)
        end

        it "lists matching messages new to old" do
          old_message = create(:text_message, body: "Apples", created_at: 3.days.ago)
          new_message = create(:text_message, body: "Apples and Oranges", created_at: 2.days.ago)
          create(:text_message, body: "Oranges", created_at: 1.day.ago)

          get "/search/apples"

          expect(response.status).to eq(200)
          expect(response.content).to eq(
            "messages" => [
              {
                "body" => new_message.body,
                "created_at" => new_message.created_at,
                "id" => new_message.id,
                "room_id" => new_message.room_id,
                "starred" => new_message.starred?,
                "type" => new_message.type,
                "user_id" => new_message.user_id
              },
              {
                "body" => old_message.body,
                "created_at" => old_message.created_at,
                "id" => old_message.id,
                "room_id" => old_message.room_id,
                "starred" => old_message.starred?,
                "type" => old_message.type,
                "user_id" => old_message.user_id
              },
            ]
          )
        end

        it "is limited to 50 results" do
          create_list(:text_message, 51, body: "Apples")

          get "/search/apples"

          expect(response.status).to eq(200)
          expect(response.content.to_hash["messages"]).to have(50).messages
        end
      end

      context "when unauthenticated" do
        it "requires authentication" do
          get "/search/apples"

          expect(response.status).to eq(401)
        end
      end
    end

    describe "GET /search" do
      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          authenticate(user.api_auth_token)
        end

        it "lists matching messages new to old" do
          old_message = create(:text_message, body: "Apples", created_at: 3.days.ago)
          new_message = create(:text_message, body: "Apples and Oranges", created_at: 2.days.ago)
          create(:text_message, body: "Oranges", created_at: 1.day.ago)

          get "/search?q=apples"

          expect(response.status).to eq(200)
          expect(response.content).to eq(
            "messages" => [
              {
                "body" => new_message.body,
                "created_at" => new_message.created_at,
                "id" => new_message.id,
                "room_id" => new_message.room_id,
                "starred" => new_message.starred?,
                "type" => new_message.type,
                "user_id" => new_message.user_id
              },
              {
                "body" => old_message.body,
                "created_at" => old_message.created_at,
                "id" => old_message.id,
                "room_id" => old_message.room_id,
                "starred" => old_message.starred?,
                "type" => old_message.type,
                "user_id" => old_message.user_id
              },
            ]
          )
        end

        it "is limited to 50 results" do
          create_list(:text_message, 51, body: "Apples")

          get "/search?q=apples"

          expect(response.status).to eq(200)
          expect(response.content.to_hash["messages"]).to have(50).messages
        end

        it "returns no results when given no query" do
          create(:text_message)

          get "/search"

          expect(response.status).to eq(200)
          expect(response.content.to_hash["messages"]).to have(0).messages
        end
      end

      context "when unauthenticated" do
        it "requires authentication" do
          get "/search?q=apples"

          expect(response.status).to eq(401)
        end
      end
    end
  end
end
