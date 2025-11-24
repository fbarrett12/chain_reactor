require "rails_helper"

RSpec.describe EdiRules do
  it "loads config and returns rules for a vendor" do
    # Assumes you created config/edi_rules.yml as described earlier
    rules = described_class.for("home_depot")

    expect(rules[:required_fields]).to be_an(Array)
    expect(rules[:mappings]).to be_a(Hash)
  end

  it "raises for unknown vendor" do
    expect { described_class.for("unknown_vendor") }.to raise_error(KeyError)
  end
end
