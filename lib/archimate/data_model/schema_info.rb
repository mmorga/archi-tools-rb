# frozen_string_literal: true

module Archimate
  module DataModel
    class SchemaInfo
      include Comparison

      # @return [String, NilClass]
      model_attr :schema
      # @return [String, NilClass]
      model_attr :schemaversion
      # @return [Array<AnyElement>]
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
