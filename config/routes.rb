Rails.application.routes.draw do
  # Root banner
  root "status#index"

  # Health endpoints
  get "/health", to: "status#health"
  get "/up",     to: "status#health" 

  namespace :api do
    namespace :v1 do
      resources :uploads, only: %i[index show create]
    end
  end
end
