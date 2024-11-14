Rails.application.routes.draw do
  # Authentication routes
  resources :users, only: [ :create ]
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # User routes
  constraints Authentication::Authenticated do
    resources :chats, only: [ :show, :create, :destroy ] do
      resources :messages, only: [ :create ]
    end
  end

  # Admin routes
  constraints Authentication::Admin do
    mount MissionControl::Jobs::Engine, at: "/jobs"

    resources :documents
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "static#index"
end
