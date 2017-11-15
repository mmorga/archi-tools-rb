# frozen_string_literal: true

require "nokogiri"

module Archimate
  module FileFormats
    class ArchiFileReader
      def initialize(doc)
        @string_or_io = doc
      end

      def parse
        handler_factory = Sax::Archi::ArchiHandlerFactory.new
        parser = Nokogiri::XML::SAX::Parser.new(Sax::Document.new(handler_factory))
        parser.parse(@string_or_io)
        model = parser.document.model
        model
          .diagrams
          .flat_map(&:connections)
          .each do |connection|
            connection.bendpoints.each do |bendpoint|
              bendpoint.x += connection.start_location.x.to_i
              bendpoint.y += connection.start_location.y.to_i
            end
          end
        model
      end
    end
  end
end
