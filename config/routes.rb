Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root "posts#index"
  resources :categories, only: :show

  resources :posts do
    resources :comments

    member do
      post :collect
      post :uncollect
    end
  end

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
    root "posts#index"
    resources :categories
    resources :users
  end
end
