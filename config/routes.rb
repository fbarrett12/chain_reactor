Rails.application.routes.draw do
  # Simple JSON health endpoint
  get "/health", to: proc { [200, { "Content-Type" => "application/json" }, [{ status: "ok" }.to_json]] }

  # Simple root page (could be JSON or HTML)
  root to: proc {
    [
      200,
      { "Content-Type" => "application/json" },
      [{ name: "Chain Reactor EDI Normalizer API", status: "running" }.to_json]
    ]
  }

  namespace :api do
    namespace :v1 do
      resources :uploads, only: %i[index show create]
    end
  end
end
