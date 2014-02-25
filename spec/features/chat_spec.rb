require "spec_helper"

feature "Chat", js: true do
  scenario "A user can chat with another user" do
    # See: https://github.com/jonleighton/poltergeist/issues/417
    pending "Poltergeist lacks SSE support"

    john, jane = create_pair(:user)
    room = create(:room)

    using_session(:john) do
      authenticate(john)
      visit room_path(room)
    end

    using_session(:jane) do
      authenticate(jane)
      visit room_path(room)

      fill_in "Message", with: "Hello, John."
      click_button "Send"
    end

    using_session(:john) do
      messages = all("#message-list li")
      expect(messages).to have(1).message
    end
  end
end
