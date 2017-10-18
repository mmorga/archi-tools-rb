# frozen_string_literal: true

module Archimate
  module DataModel
    class SchemaInfo
      include Comparison

      # @!attribute [r] schema
      #   @return [String, NilClass]
      model_attr :schema
      # @!attribute [r] schemaversion
      #   @return [String, NilClass]
      model_attr :schemaversion
      # @!attribute [r] elements
      #   @return [Array<AnyElement>]
      model_attr :elements

      def initialize(schema: nil, schemaversion: nil, elements: [])
        @schema = schema
        @schemaversion = schemaversion
        @elements = elements
      end

      def to_s
        "#{type.light_black}[#{schema} #{schemaversion}]"
      end
    end
  end
end
