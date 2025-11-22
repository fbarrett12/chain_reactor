require "csv"

class CsvParser
  def initialize(upload)
    @upload = upload
  end

  def call
    data = []

    @upload.file.open do |io|
      csv = CSV.new(io, headers: true)
      csv.each do |row|
        data << row.to_h.symbolize_keys
      end
    end

    data
  end
end
