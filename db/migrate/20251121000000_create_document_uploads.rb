class CreateDocumentUploads < ActiveRecord::Migration[7.1]
  def change
    create_table :document_uploads do |t|
      t.string :vendor, null: false
      t.string :status, null: false, default: "pending"
      t.jsonb :normalized_payload, null: false, default: {}
      t.string :webhook_url
      t.datetime :processed_at
      t.string :external_reference # optional: client-provided id
      t.text :error_message

      t.timestamps
    end

    add_index :document_uploads, :vendor
    add_index :document_uploads, :status
    add_index :document_uploads, :external_reference
  end
end
