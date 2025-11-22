class EdiRules
  CONFIG_PATH = Rails.root.join("config", "edi_rules.yml")

  def self.for(vendor)
    all.fetch(vendor.to_s) do
      raise KeyError, "No EDI rules configured for vendor=#{vendor}"
    end
  end

  def self.all
    @all ||= YAML.load_file(CONFIG_PATH).deep_symbolize_keys
  end
end
