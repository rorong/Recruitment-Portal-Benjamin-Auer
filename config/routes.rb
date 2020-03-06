Rails.application.routes.draw do
  require 'sidekiq/web'
  require 'sidekiq-scheduler/web'
  mount Sidekiq::Web => '/sidekiq'
  root to: 'dashboards#index'

  resources :dashboards do
    member do
      get :find_job_detail
    end
  end

  namespace :admins do
    resources :users
    get '/plan' => 'users#existing_plan', as: :plan
    get '/new_plan' => 'users#new_plan', as: :new_plan
    post '/create_plan' => 'users#create_plan', as: :create_plan
    get '/edit_plan' => 'users#edit_plan', as: :edit_plan
    put '/update_plan' => 'users#update_plan', as: :update_plan
    delete '/delete_plan' => 'users#delete_plan', as: :delete_plan
    get '/new_email_plan' => 'users#new_email_plan', as: :new_email_plan
    post '/create_email_plan' => 'users#create_email_plan', as: :create_email_plan
    get '/email' => 'users#email_plan'
    get '/edit_email' => 'users#edit_email'
    put '/update_email' => 'users#update_email'
    delete '/cancel_subscription/:id' => 'users#cancel_subscription', as: :cancel_subscription
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'dashboard' => 'dashboards#dashboard', as: 'user_dashboard'
  post 'seacrh_job', to: 'dashboards#seacrh_job'
  post 'create_job_detail', to: 'dashboards#create_job_detail'
  patch 'update_job_detail', to: 'dashboards#update_job_detail'
  get 'destroy_job_detail', to: 'dashboards#destroy_job_detail'
  get 'display_karriere', to: 'dashboards#display_karriere'
  get 'display_derstandard', to: 'dashboards#display_derstandard'
  devise_for :admins, path: 'admin', controllers: { sessions: "admins/sessions", registrations: 'admins' }

  devise_for :users, controllers: { registrations: 'registrations' }

  resources :billings
  resources :subscriptions
  get '/card/new' => 'billings#new_card', as: :add_payment_method
  post '/card' => 'billings#create_card', as: :create_payment_method
  get '/success' => 'billings#success', as: :success
  get '/payment_form' => 'subscriptions#payment_form', as: :payment_form
  get '/send_job_mail' => 'subscriptions#send_job_mail', as: :send_job_mail
  get '/subscription_dashboard' => 'subscriptions#subscription_dashboard', as: :subscription_dashboard
  get '/cancel_subscription' => 'subscriptions#cancel_subscription', as: :cancel_subscription
  # resource :subscription

  devise_scope :user do
    put '/update_user_details/:id', to:'registrations#update_user_details', as: :update_user_details
  end

  post '/email_package' => 'dashboards#email_package'
end
