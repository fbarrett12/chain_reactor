require "rails_helper"

RSpec.describe AiFieldEnricher do
  let(:rules) do
    {
      required_fields: %w[vendor_sku upc country_of_origin]
    }
  end

  let(:records) do
    [
      { vendor_sku: "SKU123", upc: "111111111111", country_of_origin: "US" },
      { vendor_sku: "SKU456", upc: nil, country_of_origin: nil }
    ]
  end

  it "does not modify records that have all required fields" do
    enricher = described_class.new([records.first], rules)
    result = enricher.call.first

    expect(result[:vendor_sku]).to eq("SKU123")
    expect(result[:_ai_suggestions]).to be_nil
  end

  it "adds AI suggestions for missing fields" do
    enricher = described_class.new([records.second], rules)
    result = enricher.call.first

    expect(result[:_ai_suggestions]).to be_present
    expect(result[:_ai_suggestions].keys).to match_array(%w[upc country_of_origin])
    expect(result[:upc]).to be_present
    expect(result[:country_of_origin]).to be_present
  end
end
