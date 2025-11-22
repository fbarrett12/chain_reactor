class JsonParser
  def initialize(upload)
    @upload = upload
  end

  def call
    @upload.file.open do |io|
      json = JSON.parse(io.read)
      # Accept either array of objects or single object
      records = json.is_a?(Array) ? json : [json]
      records.map { |r| r.symbolize_keys }
    end
  end
end
