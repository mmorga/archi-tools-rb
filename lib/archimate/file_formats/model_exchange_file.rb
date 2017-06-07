# frozen_string_literal: true

require "nokogiri"

module Archimate
  module FileFormats
    class ModelExchangeFile
      # Reads an Archimate::DataModel::Model from an IO containing a model
      # exchange format.
      #
      # @param input [IO] Contains the XML string of the file
      # @return Archimate::DataModel::Model
      def to_model(input)
        root = Nokogiri::XML(input)&.root
        return nil if root.nil?
        parse_model(root)
      end

      # Writes the Model Exchange XML format version of the given model to
      # the given IO.
      #
      # @param model [Archimate::DataModel::Model] Model to convert to Model
      #   Exchange Format
      # @return [String] String containing XML Model Exchange Format.
      def to_string(model); end
    end
  end
end
