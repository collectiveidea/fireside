OpenChat::Application.routes.draw do
  get "users/me"  => "users#current", as: nil
  get "users/:id" => "users#show"

  get "rooms"    => "rooms#index",    as: nil
  get "presence" => "rooms#presence", as: nil

  get  "room/:id"        => "rooms#show"
  put  "room/:id"        => "rooms#update"
  post "room/:id/join"   => "rooms#join"
  post "room/:id/leave"  => "rooms#leave"
  post "room/:id/lock"   => "rooms#lock"
  post "room/:id/unlock" => "rooms#unlock"

  get  "room/:room_id/recent" => "messages#index"
  post "room/:room_id/speak"  => "messages#create"

  post   "messages/:id/star" => "messages#star"
  delete "messages/:id/star" => "messages#unstar"
end
