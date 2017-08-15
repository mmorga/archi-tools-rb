# frozen_string_literal: true

module Archimate
  module DataModel
    # An enumeration of data types.
    DataType = String # Strict::String.default("string").enum("string", "boolean", "currency", "date", "time", "number")

    # A Property definition type containing its unique identifier, name, and data type.
    class PropertyDefinition
      include Comparison

      model_attr :id # Identifier
      model_attr :name # LangString
      model_attr :documentation # PreservedLangString.optional.default(nil)
      # model_attr :other_elements # Strict::Array.member(AnyElement).default([])
      # model_attr :other_attributes # Strict::Array.member(AnyAttribute).default([])
      model_attr :type # DataType.optional.default(nil)

      def self.identifier_for_key(key)
        (self.class.hash ^ key.hash).to_s(16)
      end

      def initialize(id:, name:, documentation: nil, type: nil)
        @id = id
        @name = name
        @documentation = documentation
        @type = type
      end
    end
  end
end
