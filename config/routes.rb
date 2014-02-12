Fireside::Application.routes.draw do
  get "account" => "accounts#show", as: nil

  get "users/me"  => "users#current", as: nil
  get "users/:id" => "users#show"

  get "rooms"    => "rooms#index",   as: nil
  get "presence" => "rooms#current", as: nil

  get  "room/:id"        => "rooms#show"
  put  "room/:id"        => "rooms#update"
  post "room/:id/join"   => "rooms#join"
  post "room/:id/leave"  => "rooms#leave"
  post "room/:id/lock"   => "rooms#lock"
  post "room/:id/unlock" => "rooms#unlock"

  get "room/:room_id/recent"                       => "messages#index"
  get "room/:room_id/transcript"                   => "messages#today"
  get "room/:room_id/transcript/:year/:month/:day" => "messages#date",
    constraints: { year: /\d{4}/, month: /\d{2}/, day: /\d{2}/ }

  post "room/:room_id/speak" => "messages#create"

  get "room/:room_id/live" => "live_messages#index"

  post   "messages/:id/star" => "messages#star"
  delete "messages/:id/star" => "messages#unstar"

  get  "room/:room_id/uploads"                     => "uploads#index"
  post "room/:room_id/uploads"                     => "uploads#create"
  get  "room/:room_id/messages/:message_id/upload" => "uploads#show"
end
