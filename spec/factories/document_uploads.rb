FactoryBot.define do
  factory :document_upload do
    vendor { "home_depot" }
    status { "pending" }
    webhook_url { nil }
    external_reference { "EXT-123" }
    normalized_payload { {} }
    processed_at { nil }
    error_message { nil }

    trait :with_file do
      after(:build) do |upload|
        file = Rack::Test::UploadedFile.new(
          Rails.root.join("spec", "fixtures", "files", "home_depot_sample.csv"),
          "text/csv"
        )
        upload.file.attach(io: file, filename: "home_depot_sample.csv", content_type: "text/csv")
      end
    end
  end
end
