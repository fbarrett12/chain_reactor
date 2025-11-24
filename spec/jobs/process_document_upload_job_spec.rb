require "rails_helper"

RSpec.describe ProcessDocumentUploadJob, type: :job do
  let(:normalizer_double) { instance_double(DocumentNormalizer, call: { foo: "bar" }) }
  let(:notifier_double)   { instance_double(WebhookNotifier, call: true) }

  before do
    # Default: any DocumentUpload -> normalizer_double
    allow(DocumentNormalizer).to receive(:new).and_return(normalizer_double)
    allow(WebhookNotifier).to receive(:new).and_return(notifier_double)
  end

  it "marks upload succeeded and triggers webhook when successful" do
    upload = create(:document_upload, webhook_url: "https://example.com/hook")

    described_class.perform_now(upload.id)

    upload.reload
    expect(upload.status).to eq("succeeded")
    expect(upload.normalized_payload).to eq("foo" => "bar")

    # It *was* called, with some DocumentUpload instance
    expect(DocumentNormalizer).to have_received(:new).with(instance_of(DocumentUpload))
    expect(WebhookNotifier).to have_received(:new).with(instance_of(DocumentUpload))
  end

  it "marks upload failed on error" do
    upload = create(:document_upload, webhook_url: "https://example.com/hook")

    # Override the default stub just for this example
    allow(DocumentNormalizer).to receive(:new).and_raise(StandardError.new("Boom!"))

    expect {
      described_class.perform_now(upload.id)
    }.to raise_error(StandardError)

    upload.reload
    expect(upload.status).to eq("failed")
    expect(upload.error_message).to include("Boom!")
  end

  it "does not trigger webhook when webhook_url is blank" do
    upload_without_hook = create(:document_upload, webhook_url: nil)

    described_class.perform_now(upload_without_hook.id)

    upload_without_hook.reload
    expect(upload_without_hook.status).to eq("succeeded")
    expect(upload_without_hook.normalized_payload).to eq("foo" => "bar")

    # Key part: WebhookNotifier.new should *never* be called
    expect(WebhookNotifier).not_to have_received(:new)
  end
end
