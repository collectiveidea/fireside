json.user do
  json.admin @user.admin?
  json.api_auth_token @user.api_auth_token
  json.avatar_url @user.avatar_url
  json.created_at @user.created_at
  json.email_address @user.email
  json.id @user.id
  json.name @user.name
end
