# frozen_string_literal: true

require "forwardable"

module Archimate
  module FileFormats
    class ArchiFileWriter
      extend Forwardable

      def_delegators :@writer, :write

      def self.write(model, output_io)
        writer = new(model)
        writer.write(output_io)
      end

      def initialize(model)
        @writer = case model.version
                  when /^3\./
                    Serializer::Archi::ArchiFileWriter3
                  else
                    Serializer::Archi::ArchiFileWriter4
                  end.new(model)
      end
    end
  end
end
