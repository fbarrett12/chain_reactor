require "rails_helper"

RSpec.describe "Api::V1::Uploads", type: :request do
  describe "POST /api/v1/uploads" do
    let(:file) do
      fixture_path = Rails.root.join("spec", "fixtures", "files", "home_depot_sample.csv")
      Rack::Test::UploadedFile.new(fixture_path, "text/csv")
    end

    it "creates a document_upload and enqueues job" do
      expect {
        post "/api/v1/uploads", params: {
          vendor: "home_depot",
          external_reference: "CLIENT-1",
          file: file
        }
      }.to change(DocumentUpload, :count).by(1)
       .and have_enqueued_job(ProcessDocumentUploadJob)

      expect(response).to have_http_status(:accepted)

      json = JSON.parse(response.body)
      expect(json["vendor"]).to eq("home_depot")
      expect(json["status"]).to eq("pending")
      expect(json["external_reference"]).to eq("CLIENT-1")
    end

    it "returns errors for invalid params" do
      post "/api/v1/uploads", params: { vendor: nil }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["errors"]).to be_present
    end
  end

  describe "GET /api/v1/uploads/:id" do
    let!(:upload) { create(:document_upload, status: "succeeded", normalized_payload: { foo: "bar" }) }

    it "returns the upload" do
      get "/api/v1/uploads/#{upload.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(upload.id)
      expect(json["status"]).to eq("succeeded")
      expect(json["normalized_payload"]).to eq("foo" => "bar")
    end
  end

  describe "GET /api/v1/uploads" do
    before do
      create_list(:document_upload, 3)
    end

    it "returns a list of uploads" do
      get "/api/v1/uploads"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(3)
    end
  end
end
