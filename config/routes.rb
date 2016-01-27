Rails.application.routes.draw do
  namespace :recipes do
    resource :featured, only: [:index, :destroy], defaults: { format: :json }, controller: :featured
  end
  resources :recipes
  resources :inventory_items, defaults: { format: :json}
  get 'orders/received', controller: :orders, action: :received, as: :received_order
  post 'order/:id/cancel', controller: :orders, action: :cancel, as: :cancel_order
  post 'order/:id/close', controller: :orders, action: :close, as: :close_order
  post 'order/:id/pay', controller: :orders, action: :pay, as: :pay_order
  resources :orders, only: [:new, :create, :index, :destroy]
  get 'weekly_menu_subscriptions/unsubscribed', controller: :weekly_menu_subscriptions, action: :unsubscribed
  resources :weekly_menu_subscriptions, only: [:create, :destroy], defaults: { format: :json }
  resources :contacts, except: [:edit, :update] do
    put :read, action: :read, as: :read, on: :member
  end
  resources :phone_callbacks, except: [:show, :edit, :update] do
    put :close, action: :close, as: :close, on: :member
  end
  devise_for :admins
  root to: 'landing#index'
end
