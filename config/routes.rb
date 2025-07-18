require "sidekiq/web"

Sidekiq::Web.use(Rack::Auth::Basic) do |username, password|
  ActiveSupport::SecurityUtils.secure_compare(username, ENV.fetch("SIDEKIQ_USERNAME")) &
    ActiveSupport::SecurityUtils.secure_compare(password, ENV.fetch("SIDEKIQ_PASSWORD"))
end

Rails.application.routes.draw do
  devise_for :users, defaults: { format: :json }
  mount Sidekiq::Web => "/sidekiq"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  resources :vehicles, only: [ :index, :create, :show, :update ]
  resources :maintenance_reports, only: [ :index, :create, :show, :update ]
  resources :service_orders, only: [ :index ]
end
