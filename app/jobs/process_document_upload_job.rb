class ProcessDocumentUploadJob < ApplicationJob
  queue_as :default

  def perform(upload_id)
    upload = DocumentUpload.find(upload_id)

    upload.mark_processing!

    payload = DocumentNormalizer.new(upload).call
    upload.mark_succeeded!(payload: payload)

    WebhookNotifier.new(upload).call if upload.webhook_url.present?
  rescue StandardError => e
    Rails.logger.error("[ProcessDocumentUploadJob] Failed: #{e.class} - #{e.message}\n#{e.backtrace.join("\n")}")
    upload&.mark_failed!(e)
    WebhookNotifier.new(upload).call if upload&.webhook_url.present?
    raise e
  end
end
