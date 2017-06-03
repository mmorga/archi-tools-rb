# frozen_string_literal: true

module Archimate
  # This File Format class supports reading and parsing from a number of ArchiMate formats
  class FileFormat
    def self.read(filename)
      case File.extname(filename)
      when ".xml"
        FileFormats::ModelExchangeFileReader.read(filename)
      when ".marshal"
        File.open(filename, "rb") do |marshal_file|
          Marshal.load(marshal_file)
        end
      else
        FileFormats::ArchiFileReader.read(filename)
      end
    end

    def self.parse(str)
      FileFormats::ArchiFileReader.parse(str)
    end
  end
end
