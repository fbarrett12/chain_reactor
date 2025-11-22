# == Schema Information
#
# Table name: document_uploads
#
#  id                 :bigint           not null, primary key
#  vendor             :string
#  status             :string
#  normalized_payload :jsonb
#  error_message      :text
#  processed_at       :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null

class DocumentUpload < ApplicationRecord
  enum status: {
    pending: "pending",
    processing: "processing",
    succeeded: "succeeded",
    failed: "failed"
  }

  has_one_attached :file # if you use ActiveStorage

  validates :vendor, presence: true
  validates :status, presence: true

  def mark_processing!
    update!(status: :processing, error_message: nil)
  end

  def mark_succeeded!(payload:)
    update!(status: :succeeded, normalized_payload: payload, processed_at: Time.current)
  end

  def mark_failed!(error)
    update!(
      status: :failed,
      error_message: error.message.truncate(500),
      processed_at: Time.current
    )
  end
end

# == Schema Information
#
# Table name: document_uploads
#
#  id                 :bigint           not null, primary key
#  vendor             :string
#  status             :string
#  normalized_payload :jsonb
#  error_message      :text
#  processed_at       :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null