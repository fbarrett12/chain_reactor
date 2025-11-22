# app/controllers/api/v1/uploads_controller.rb
class Api::V1::UploadsController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    upload = DocumentUpload.new(upload_params)
    upload.status = :pending

    if params[:file].present?
      upload.file.attach(params[:file])
    end

    if upload.save
      ProcessDocumentUploadJob.perform_later(upload.id)
      render json: serialize(upload), status: :accepted
    else
      render json: { errors: upload.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    upload = DocumentUpload.find(params[:id])
    render json: serialize(upload)
  end

  def index
    uploads = DocumentUpload.order(created_at: :desc).limit(50)
    render json: uploads.map { |u| serialize(u) }
  end

  private

  def upload_params
    params.permit(:vendor, :webhook_url, :external_reference)
  end

  def serialize(upload)
    {
      id: upload.id,
      vendor: upload.vendor,
      status: upload.status,
      external_reference: upload.external_reference,
      webhook_url: upload.webhook_url,
      processed_at: upload.processed_at,
      error_message: upload.error_message,
      normalized_payload: upload.normalized_payload
    }
  end
end
