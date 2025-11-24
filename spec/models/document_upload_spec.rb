require "rails_helper"

RSpec.describe DocumentUpload, type: :model do
  describe "validations" do
    it "is valid with vendor and status" do
      upload = build(:document_upload)
      expect(upload).to be_valid
    end

    it "is invalid without vendor" do
      upload = build(:document_upload, vendor: nil)
      expect(upload).not_to be_valid
      expect(upload.errors[:vendor]).to be_present
    end

    it "is invalid without status" do
      upload = build(:document_upload, status: nil)
      expect(upload).not_to be_valid
      expect(upload.errors[:status]).to be_present
    end
  end

  describe "#mark_processing!" do
    it "sets status to processing and clears error_message" do
      upload = create(:document_upload, status: "pending", error_message: "Some error")
      upload.mark_processing!
      expect(upload.status).to eq("processing")
      expect(upload.error_message).to be_nil
    end
  end

  describe "#mark_succeeded!" do
    it "sets status, payload and processed_at" do
      upload = create(:document_upload, status: "processing", normalized_payload: {})
      time = Time.current
      travel_to(time) do
        upload.mark_succeeded!(payload: { foo: "bar" })
      end

      expect(upload.status).to eq("succeeded")
      expect(upload.normalized_payload).to eq("foo" => "bar")
      expect(upload.processed_at.to_i).to eq(time.to_i)
    end
  end

  describe "#mark_failed!" do
    it "sets status, error_message and processed_at" do
      upload = create(:document_upload, status: "processing")
      error = StandardError.new("Boom!")

      time = Time.current
      travel_to(time) do
        upload.mark_failed!(error)
      end

      expect(upload.status).to eq("failed")
      expect(upload.error_message).to include("Boom!")
      expect(upload.processed_at.to_i).to eq(time.to_i)
    end
  end
end
