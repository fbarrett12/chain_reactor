require "rails_helper"

RSpec.describe RecordValidator do
  let(:rules) do
    {
      required_fields: %w[vendor_sku upc country_of_origin]
    }
  end

  let(:records) do
    [
      { vendor_sku: "SKU123", upc: "111111111111", country_of_origin: "US", _original: { foo: "bar" } },
      { vendor_sku: "SKU456", upc: nil, country_of_origin: nil, _original: { foo: "baz" } }
    ]
  end

  it "annotates records with missing required fields" do
    validated = described_class.new(records, rules).call

    first = validated.first
    second = validated.second

    expect(first[:_validation_errors]).to be_nil

    expect(second[:_validation_errors]).to eq(
      missing_fields: %w[upc country_of_origin]
    )
  end
end
