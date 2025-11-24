require "rails_helper"

RSpec.describe WebhookNotifier do
  let(:upload) do
    create(:document_upload,
      status: "succeeded",
      webhook_url: "https://example.com/hook",
      normalized_payload: { foo: "bar" },
      processed_at: Time.current
    )
  end

  it "posts JSON payload to webhook_url" do
    uri = URI(upload.webhook_url)
    http_double = instance_double(Net::HTTP)
    response_double = instance_double(Net::HTTPResponse, code: "200")

    expect(Net::HTTP).to receive(:new)
      .with(uri.host, uri.port)
      .and_return(http_double)

    allow(http_double).to receive(:use_ssl=).with(true)

    expect(http_double).to receive(:request) do |request|
      body = JSON.parse(request.body)
      expect(body["id"]).to eq(upload.id)
      expect(body["normalized_payload"]).to eq("foo" => "bar")
      response_double
    end

    described_class.new(upload).call
  end
end
