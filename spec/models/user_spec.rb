require "spec_helper"

describe User do
  describe "validation" do
    let(:user) { build(:user) }

    it "requires a name" do
      expect(user).to accept_values_for(:name, "John", "Jane")
      expect(user).not_to accept_values_for(:name, nil, "", " ")
    end

    it "requires a valid email address" do
      expect(user).to accept_values_for(:email, "john@example.com", "jane@example.org")
      expect(user).not_to accept_values_for(:email, nil, "", " ", "john", "jane@example")
    end

    it "requires a unique email address" do
      create(:user, email: "john@example.com")

      expect(user).to accept_values_for(:email, "jane@example.org")
      expect(user).not_to accept_values_for(:email, "john@example.com")
    end

    it "requires a password on creation" do
      user = build(:user, password: nil)

      expect(user).not_to accept_values_for(:password, nil, "", " ")
      expect(user).to accept_values_for(:password, "secret", "deep dark secret")
    end

    it "doesn't require a password on updation" do
      user = create(:user)

      expect(user).to accept_values_for(:password, nil, "", " ", "secret", "deep dark secret")
    end
  end

  describe "#avatar_url" do
    it "is the Gravatar image URL for the user's email address" do
      user = create(:user, email: "John.Doe@gmail.com ")

      uri = URI.parse(user.avatar_url)
      expect(uri.scheme).to eq("https")
      expect(uri.host).to eq("secure.gravatar.com")
      expect(uri.path).to eq("/avatar/e13743a7f1db7f4246badd6fd6ff54ff")
      query = Rack::Utils.parse_query(uri.query)
      expect(query["d"]).to eq("mm")
      expect(query["s"]).to eq("55")
    end
  end

  describe "#join_room" do
    let!(:user) { create(:user) }
    let!(:room) { create(:room) }

    context "when the user is in the room" do
      before do
        user.rooms << room
      end

      it "does nothing" do
        expect {
          user.join_room(room)
        }.not_to change {
          user.rooms.count
        }
      end
    end

    context "when the user is not in the room" do
      it "adds the user to the room" do
        expect {
          user.join_room(room)
        }.to change {
          user.rooms.count
        }.from(0).to(1)

        expect(user.rooms.first).to eq(room)
      end
    end
  end

  describe "#leave_room" do
    let!(:user) { create(:user) }
    let!(:room) { create(:room) }

    context "when the user is in the room" do
      before do
        user.rooms << room
      end

      it "removes the user from the room" do
        expect {
          user.leave_room(room)
        }.to change {
          user.rooms.count
        }.from(1).to(0)
      end
    end

    context "when the user is not in the room" do
      it "does nothing" do
        expect {
          user.leave_room(room)
        }.not_to change {
          user.rooms.count
        }
      end
    end
  end

  describe "#set_api_auth_token" do
    it "is set on creation" do
      user = create(:user, name: "John", api_auth_token: nil)

      token = user.api_auth_token
      expect(token).to be_present

      user.update!(name: "Jane")

      expect(user.api_auth_token).to eq(token)
    end
  end
end
