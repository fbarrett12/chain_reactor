require "rails_helper"

RSpec.describe DocumentNormalizer do
  let(:upload) { create(:document_upload, vendor: "home_depot") }

  let(:rules) do
    {
      required_fields: %w[vendor_sku upc],
      mappings: {
        "VendorSKU" => "vendor_sku",
        "UPCCode"   => "upc"
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

    # Default: AI is a no-op for the simple spec
    allow(AiFieldEnricher).to receive(:new).and_wrap_original do |_orig, records, _rules|
      double(call: records)
    end

    # And make validation a pass-through for these specs
    allow(RecordValidator).to receive(:new).and_wrap_original do |_orig, records, _rules|
      double(call: records)
    end
  end

  it "returns normalized payload with stats when AI is a no-op" do
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

  it "computes missing_fields_counts based on pre-AI data, not enriched values" do
    # Simulate mapped records before AI enrichment:
    # - first record missing upc
    # - second record missing vendor_sku
    mapped_records = [
      {
        vendor_sku: "HD-111",
        upc: nil,
        country_of_origin: "US",
        release_date: Date.parse("2025-04-01")
      },
      {
        vendor_sku: nil,
        upc: "222233334444",
        country_of_origin: "CN",
        release_date: Date.parse("2025-05-20")
      }
    ]

    # Simulate AI enrichment filling in those missing fields
    enriched_records = [
      mapped_records[0].merge(upc: "AI_TODO_upc"),
      mapped_records[1].merge(vendor_sku: "AI_TODO_vendor_sku")
    ]

    normalizer = described_class.new(upload)

    # We don't care about actual parsing here, just the pipeline stages:
    allow(normalizer).to receive(:parse_file).and_return(:raw_data_ignored)
    allow(normalizer).to receive(:map_fields).and_return(mapped_records)
    allow(normalizer).to receive(:enrich_with_ai).and_return(enriched_records)
    allow(normalizer).to receive(:validate).and_return(enriched_records)

    result = normalizer.call

    expect(result[:records]).to eq(enriched_records)

    # Critical assertion: stats are based on the mapped (pre-AI) data,
    # so they should still see the originally-missing fields.
    expect(result[:stats][:missing_fields_counts]).to eq(
      "vendor_sku" => 1,
      "upc"        => 1
    )
  end
end
