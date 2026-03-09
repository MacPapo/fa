Rails.application.routes.draw do
  resource :session

  concern :searchable do
    resources :searches, only: [ :index ]
  end

  resources :jobs

  namespace :locations do
    concerns :searchable
  end

  namespace :contacts do
    concerns :searchable
  end

  resources :locations
  resources :contacts

  resources :searches, only: [ :index ]

  get "up" => "rails/health#show", as: :rails_health_check
  root "jobs#index"
end
