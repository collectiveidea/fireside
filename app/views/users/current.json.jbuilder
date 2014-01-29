json.user do
  json.partial! @user
  json.api_auth_token @user.api_auth_token
end
