# frozen_string_literal: true
module Archimate
  class FileFormat
    def self.read(filename)
      ArchiFileReader.read(filename)
    end
  end
end
