require "rails_helper"

RSpec.describe DocumentNormalizer do
  let(:upload) { create(:document_upload, vendor: "home_depot") }

  let(:rules) do
    {
      required_fields: %w[vendor_sku upc],
      mappings: {
        "VendorSKU": "vendor_sku",
        "UPCCode": "upc"
      }
    }
  end

  let(:raw_data) do
    [
      { "VendorSKU" => "SKU123", "UPCCode" => "111111111111" },
      { "VendorSKU" => "SKU456", "UPCCode" => nil }
    ]
  end

  before do
    allow(EdiRules).to receive(:for).with("home_depot").and_return(rules)

    fake_parser = instance_double("CsvParser", call: raw_data)
    allow(ParserFactory).to receive(:build).with(upload).and_return(fake_parser)

    # Make AI a no-op for this spec so we can reason about missing fields
    allow(AiFieldEnricher).to receive(:new).and_wrap_original do |orig, records, rules|
      double(call: records)
    end
  end

  it "returns normalized payload with stats" do
    payload = described_class.new(upload).call

    expect(payload[:vendor]).to eq("home_depot")
    expect(payload[:records].size).to eq(2)

    record1 = payload[:records].first
    record2 = payload[:records].second

    expect(record1[:vendor_sku]).to eq("SKU123")
    expect(record1[:upc]).to eq("111111111111")

    expect(record2[:vendor_sku]).to eq("SKU456")
    expect(record2[:upc]).to be_nil

    expect(payload[:stats][:total_records]).to eq(2)
    # Only UPC is missing once
    expect(payload[:stats][:missing_fields_counts]).to eq({ "upc" => 1 })
  end
end
