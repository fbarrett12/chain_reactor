class FieldMapper
  def initialize(raw_data, rules)
    @raw_data = raw_data
    @rules = rules
    @mapping = rules.fetch(:mappings, {})
  end

  def call
    @raw_data.map do |row|
      mapped = {}

      @mapping.each do |source, target|
        mapped[target.to_sym] = row[source.to_sym] || row[source.to_s]
      end

      # Original row is included for debugging
      mapped[:_original] = row
      mapped
    end
  end
end
