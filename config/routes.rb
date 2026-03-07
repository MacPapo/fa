Rails.application.routes.draw do
  resource :session

  concern :searchable do
    resources :searches, only: [ :index ]
  end

  resources :jobs

  # 1. Rotte standard (per i modali di creazione)
  resources :locations, only: [ :create ]
  resources :photographers, only: [ :create ]
  resources :clients, only: [ :create ]
  resources :subjects, only: [ :create ]

  # 2. Namespace per le ricerche (Autocomplete)
  namespace :locations do
    concerns :searchable
  end

  namespace :photographers do
    concerns :searchable
  end

  namespace :clients do
    concerns :searchable
  end

  namespace :subjects do
    concerns :searchable
  end

  get "up" => "rails/health#show", as: :rails_health_check
  root "jobs#index"
end
