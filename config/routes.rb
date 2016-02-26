Rails.application.routes.draw do
  namespace :recipes do
    resource :featured, only: [:index, :destroy], defaults: { format: :json }, controller: :featured
  end
  resources :recipes
  resources :inventory_items, defaults: { format: :json}
  get 'orders/received/:id', controller: :orders, action: :received, as: :received_order
  get 'orders/failed', controller: :orders, action: :failed, as: :failed_order
  resources :orders, only: [:new, :create, :index, :destroy] do
    post :cancel, action: :cancel, on: :member
    post :close, action: :close, on: :member
  end
  resources :weekly_menu_subscriptions, only: [:show, :create], defaults: { format: :json } do
    get :unsubscribe, action: :destroy, on: :member
    get :unsubscribed, action: :unsubscribed, on: :collection
    post :deliver, action: :deliver, on: :collection
  end
  resources :contacts, except: [:edit, :update] do
    put :read, action: :read, as: :read, on: :member
  end
  resources :phone_callbacks, except: [:show, :edit, :update] do
    put :close, action: :close, as: :close, on: :member
  end
  resource :policy, only: [:show], controller: :policy
  resource :offer, only: [:show], controller: :offer
  devise_for :admins
  resource :yandex_kassa, only: [], controller: :yandex_kassa, defaults: { format: :xml } do
    post :paymentAviso, on: :collection
    post :checkOrder, on: :collection
    get :checkOrder, on: :collection
    post :cancelOrder, on: :collection
    get :pay, on: :collection
  end
  root to: 'landing#index'
end
