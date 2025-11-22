require "net/http"

class WebhookNotifier
  def initialize(upload)
    @upload = upload
  end

  def call
    uri = URI(@upload.webhook_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"

    req = Net::HTTP::Post.new(uri.path.presence || "/", { "Content-Type" => "application/json" })
    req.body = webhook_body.to_json

    http.request(req)
  rescue StandardError => e
    Rails.logger.error("[WebhookNotifier] Failed for upload=#{@upload.id}: #{e.class} - #{e.message}")
  end

  private

  def webhook_body
    {
      id: @upload.id,
      external_reference: @upload.external_reference,
      status: @upload.status,
      vendor: @upload.vendor,
      processed_at: @upload.processed_at,
      error_message: @upload.error_message,
      normalized_payload: @upload.normalized_payload
    }
  end
end
