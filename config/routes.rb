Rails.application.routes.draw do
  resources :week_recipes, only: [:update, :index]
  resources :recipes
  resources :inventory_items, defaults: { format: :json}
  devise_for :admins
  root to: 'landing#index'
end
