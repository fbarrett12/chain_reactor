# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # In dev: allow the Vite dev server (React UI)
    origins "http://localhost:5173",
            "https://chain-reactor-ui.vercel.app"

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head]
  end
end
