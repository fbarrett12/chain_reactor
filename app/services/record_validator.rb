class RecordValidator
  ValidationResult = Struct.new(:records, :errors, keyword_init: true)

  def initialize(records, rules)
    @records = records
    @required = Array(rules[:required_fields])
  end

  def call
    errors = []

    @records.each_with_index do |record, idx|
      missing = @required.select { |field| record[field.to_sym].blank? }
      next if missing.empty?

      errors << {
        index: idx,
        missing_fields: missing,
        original: record[:_original]
      }
    end

    # For now we just attach errors on the payload
    @records.each_with_index do |record, idx|
      error = errors.find { |e| e[:index] == idx }
      record[:_validation_errors] = error&.slice(:missing_fields)
    end

    @records
  end
end
