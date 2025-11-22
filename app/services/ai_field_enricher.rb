class AiFieldEnricher
  def initialize(records, rules)
    @records = records
    @rules = rules
    @required = Array(rules[:required_fields])
  end

  def call
    # For weekend scope: only call AI for records missing required fields
    @records.map do |record|
      missing = @required.select { |f| record[f.to_sym].blank? }
      next record if missing.empty?

      suggestions = fetch_suggestions(record, missing)
      merged = record.dup

      suggestions.each do |field, value|
        merged[field.to_sym] ||= value
      end

      merged[:_ai_suggestions] = suggestions
      merged
    end
  end

  private

  def fetch_suggestions(record, missing_fields)
    # ------- STUB IMPLEMENTATION -------
    # Replace with Azure OpenAI or similar.
    #
    # Example shape:
    # client = Azure::OpenAI::Client.new(api_key: ENV["AZURE_OPENAI_KEY"], ...)
    # prompt = build_prompt(record, missing_fields)
    # response = client.chat(...)

    Rails.logger.info("[AI] Generating suggestions for missing=#{missing_fields} record=#{record.except(:_original)}")

    # For now, just return a hash with "TODO" values to prove the pipeline works:
    missing_fields.to_h { |field| [field, "AI_TODO_#{field}"] }
  end
end
