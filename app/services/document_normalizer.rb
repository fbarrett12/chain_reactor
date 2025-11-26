class DocumentNormalizer
  def initialize(upload)
    @upload = upload
    @rules  = EdiRules.for(upload.vendor)
  end

  def call
    raw_data = parse_file
    mapped   = map_fields(raw_data)

    # 👇 compute stats BEFORE AI fills anything in
    missing_stats = missing_field_stats(mapped)

    enriched  = enrich_with_ai(mapped)
    validated = validate(enriched)

    {
      vendor: @upload.vendor,
      external_reference: @upload.external_reference,
      records: validated,
      stats: {
        total_records: validated.size,
        missing_fields_counts: missing_stats
      }
    }
  end

  private

  def parse_file
    ParserFactory.build(@upload).call
  end

  def map_fields(raw_data)
    FieldMapper.new(raw_data, @rules).call
  end

  def enrich_with_ai(mapped)
    AiFieldEnricher.new(mapped, @rules).call
  rescue StandardError => e
    Rails.logger.warn("[AI] Failed to enrich fields: #{e.class} - #{e.message}")
    mapped
  end

  def validate(enriched)
    RecordValidator.new(enriched, @rules).call
  end

  def missing_field_stats(records)
    required = Array(@rules.dig(:required_fields))
    counts   = Hash.new(0)

    records.each do |rec|
      required.each do |field|
        counts[field] += 1 if rec[field.to_sym].blank?
      end
    end

    counts
  end
end
