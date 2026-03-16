Rails.application.routes.draw do
  resource :session
  resources :users, only: [ :show, :edit, :update ]

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

  namespace :jobs do
    resources :locations, only: [ :new, :create ]
    resources :contacts, only: [ :new, :create ]
  end

  get "up" => "rails/health#show", as: :rails_health_check
  root "jobs#index"
end
