require "rails_helper"

RSpec.describe FieldMapper do
  let(:rules) do
    {
      mappings: {
        "VendorSKU": "vendor_sku",
        "UPCCode": "upc"
      }
    }
  end

  let(:raw_data) do
    [
      { VendorSKU: "SKU123", UPCCode: "111111111111" }.stringify_keys,
      { "VendorSKU" => "SKU456", "UPCCode" => "222222222222" }
    ]
  end

  it "maps source fields to canonical fields" do
    mapped = described_class.new(raw_data, rules).call

    expect(mapped.size).to eq(2)
    expect(mapped.first[:vendor_sku]).to eq("SKU123")
    expect(mapped.first[:upc]).to eq("111111111111")
    expect(mapped.first[:_original]).to eq(raw_data.first)
  end
end
