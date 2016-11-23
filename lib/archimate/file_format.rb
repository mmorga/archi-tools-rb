# frozen_string_literal: true
module Archimate
  class FileFormat
    def self.read(filename)
      ArchiFileReader.read(filename)
    end

    def self.parse(str)
      ArchiFileReader.parse(str)
    end
  end
end
