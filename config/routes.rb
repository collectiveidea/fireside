OpenChat::Application.routes.draw do
  get "rooms" => "rooms#index"
  get "presence" => "rooms#presence"

  resources :rooms, path: "room", only: [:show, :update] do
    post :join, :leave, :lock, :unlock, on: :member
  end

  scope defaults: { format: :json } do
    resources :messages, only: [:index, :create]
  end
end
