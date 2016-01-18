Rails.application.routes.draw do
  get 'recipes/featured', controller: :featured_recipes, action: :index, format: :json
  resources :recipes
  resources :inventory_items, defaults: { format: :json}
  get 'orders/received', controller: :orders, action: :received, as: :received_order
  post 'order/:id/cancel', controller: :orders, action: :cancel, as: :cancel_order
  post 'order/:id/close', controller: :orders, action: :close, as: :close_order
  post 'order/:id/pay', controller: :orders, action: :pay, as: :pay_order
  resources :orders, only: [:new, :create, :index, :destroy]
  get 'weekly_menu_subscriptions/unsubscribed', controller: :weekly_menu_subscriptions, action: :unsubscribed
  resources :weekly_menu_subscriptions, only: [:create, :destroy], defaults: { format: :json }
  devise_for :admins
  root to: 'landing#index'
end
