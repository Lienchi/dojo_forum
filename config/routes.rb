Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root "posts#index"

  resources :posts do
    resources :comments

    member do
      post :collect
      post :uncollect
    end
  end

  resources :feeds, only: [:index]

  resources :users, only: [:show, :edit, :update] do
    member do
      get :comments
      get :collects
      get :drafts
      get :friends
    end
  end

  resources :friendships, only: [:create, :destroy] do
    member do
      post :accept
    end
  end

  namespace :admin do
    root "categories#index"
    resources :categories
    resources :users
  end

  namespace :api, defaults: {format: :json} do
    namespace :v1 do

      post "/login" => "auth#login"
      post "/logout" => "auth#logout"

      resources :posts, only: [:index, :create, :show, :update, :destroy]
    end
  end
end
