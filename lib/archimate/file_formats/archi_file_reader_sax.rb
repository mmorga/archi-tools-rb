# frozen_string_literal: true
require "nokogiri"

module Archimate
  module FileFormats
    class ArchiFileReaderSax
      def initialize(doc)
        @string_or_io = doc
      end

      def parse()
        # TODO: examine the file to determine the proper SaxHandlerFactory
        handler_factory = Archi::ArchiV2HandlerFactory.new
        parser = Nokogiri::XML::SAX::Parser.new(ArchiSaxDocument.new(handler_factory))
        parser.parse(@string_or_io)
        parser.document.model
      end
    end
  end
end
