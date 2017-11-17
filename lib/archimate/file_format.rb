# frozen_string_literal: true

require "nokogiri"

module Archimate
  # This File Format class supports reading and parsing from a number of ArchiMate formats
  class FileFormat
    def self.read(filename)
      case File.extname(filename)
      when ".marshal"
        File.open(filename, "rb") do |marshal_file|
          Marshal.load(marshal_file)
        end
      else
        parse(File.read(filename))
      end
    end

    def self.parse(str)
      doc = Nokogiri::XML(str)
      case doc.namespaces["xmlns"]
      when "http://www.opengroup.org/xsd/archimate/3.0/",
           "http://www.opengroup.org/xsd/archimate"
        FileFormats::ModelExchangeFileReader.new(str).parse
      else
        FileFormats::ArchiFileReader.new(str).parse
      end
    end
  end
end
