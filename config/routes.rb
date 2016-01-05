Rails.application.routes.draw do
  resources :inventory_items, defaults: { format: :json}
  devise_for :admins
  root to: 'landing#index'
end
