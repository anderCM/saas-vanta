Rails.application.routes.draw do
  root "dashboard#index"
  resource :session
  get "login", to: "sessions#new", as: :login
  resources :passwords, param: :token
  resources :invitations, only: [ :edit, :update ], param: :token

  namespace :admin do
    resources :enterprises, only: [ :new, :create ]
    resource :dashboard, only: [ :show ]
  end

  resources :enterprises, only: [ :index ] do
    member do
      post :select
    end
  end

  resources :products
  resources :providers
  resources :customers

  resources :bulk_imports, only: [ :index, :show, :new, :create ] do
    collection do
      get :template
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
