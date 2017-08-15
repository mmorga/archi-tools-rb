# frozen_string_literal: true

module Archimate
  module DataModel
    class SchemaInfo
      include Comparison

      model_attr :schema # Strict::String.optional
      model_attr :schemaversion # Strict::String.optional
      model_attr :elements # Strict::Array.member(AnyElement).default([])

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
