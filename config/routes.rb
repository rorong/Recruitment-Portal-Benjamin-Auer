Rails.application.routes.draw do
  root to: 'dashboards#index'
  # devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post 'seacrh_job', to: 'dashboards#seacrh_job'
  get 'display', to: 'dashboards#display'
  devise_for :users, :controllers => {:registrations => "registrations"}

  resources :billings
  resources :subscriptions
  get '/card/new' => 'billings#new_card', as: :add_payment_method
  post '/card' => 'billings#create_card', as: :create_payment_method
  get '/success' => 'billings#success', as: :success
  get '/fetch_plan' => 'subscriptions#fetch_plan', as: :fetch_plan
  get '/payment_form' => 'subscriptions#payment_form', as: :payment_form
  get '/send_job_mail' => 'subscriptions#send_job_mail', as: :send_job_mail
  get '/subscription_dashboard' => 'subscriptions#subscription_dashboard', as: :subscription_dashboard
  # resource :subscription

end
