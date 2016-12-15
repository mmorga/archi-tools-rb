# frozen_string_literal: true
module Archimate
  class FileFormat
    def self.read(filename, aio)
      FileFormats::ArchiFileReader.read(filename, aio)
    end

    def self.parse(str, aio)
      FileFormats::ArchiFileReader.parse(str, aio)
    end
  end
end
