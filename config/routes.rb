Rails.application.routes.draw do
  get 'recipes/featured', controller: :featured_recipes, action: :index, format: :json
  resources :recipes
  resources :inventory_items, defaults: { format: :json}
  devise_for :admins
  root to: 'landing#index'
end
