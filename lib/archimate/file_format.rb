# frozen_string_literal: true
module Archimate
  class FileFormat
    def self.read(filename)
      FileFormats::ArchiFileReader.read(filename)
    end

    def self.parse(str)
      FileFormats::ArchiFileReader.parse(str)
    end
  end
end
