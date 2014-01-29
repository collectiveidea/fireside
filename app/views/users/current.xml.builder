xml.user do
  xml << render(@user)
  xml.tag! "api-auth-token", @user.api_auth_token
end
