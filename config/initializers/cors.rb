# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # In dev: allow the Vite dev server (React UI)
    origins "http://localhost:5173"

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head]
  end

  # In production we will do something like:
  #
  # allow do
  #   origins "https://your-frontend-domain.com"
  #
  #   resource "*",
  #     headers: :any,
  #     methods: %i[get post put patch delete options head]
  # end
end
