Fireside::Application.routes.draw do
  scope defaults: { format: :json } do
    resources :messages, only: [:index, :create]
  end
end
