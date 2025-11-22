class ParserFactory
  def self.build(upload)
    filename = upload.file&.filename.to_s

    case File.extname(filename).downcase
    when ".csv"  then CsvParser.new(upload)
    when ".json" then JsonParser.new(upload)
    when ".xml"  then XmlParser.new(upload) # optional
    else
      raise ArgumentError, "Unsupported file type: #{filename}"
    end
  end
end
