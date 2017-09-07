# frozen_string_literal: true

module Archimate
  module DataModel
    # An enumeration of data types.
    DataType = String #String.default("string").enum("string", "boolean", "currency", "date", "time", "number")

    # A Property definition type containing its unique identifier, name, and data type.
    class PropertyDefinition
      include Comparison

      # @return [String]
      model_attr :id
      # @return [LangString]
      model_attr :name
      # @return [PreservedLangString, NilClass]
      model_attr :documentation
      # # @return [Array<AnyElement>]
      model_attr :other_elements
      # # @return [Array<AnyAttribute>]
      model_attr :other_attributes
      # @return [DataType, NilClass]
      model_attr :type

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
