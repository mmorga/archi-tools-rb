# frozen_string_literal: true
module Archimate
  class FileFormat
    def self.read(filename, aio)
      case File.extname(filename)
      when ".xml"
        FileFormats::ModelExchangeFileReader.read(filename, aio)
      when ".marshal"
        File.open(filename, "rb") do |f|
          Marshal.load(f)
        end
      else
        FileFormats::ArchiFileReader.read(filename, aio)
      end
    end

    def self.parse(str, aio)
      FileFormats::ArchiFileReader.parse(str, aio)
    end
  end
end
