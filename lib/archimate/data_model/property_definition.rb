# frozen_string_literal: true

module Archimate
  module DataModel
    # An enumeration of data types.
    DataType = Strict::String.default("string").enum("string", "boolean", "currency", "date", "time", "number")

    # A Property definition type containing its unique identifier, name, and data type.
    class PropertyDefinition < Dry::Struct
      # specifies constructor style for Dry::Struct
      constructor_type :strict_with_defaults

      attribute :id, Identifier
      attribute :name, LangString
      attribute :documentation, PreservedLangString.optional.default(nil)
      # attribute :other_elements, Strict::Array.member(AnyElement).default([])
      # attribute :other_attributes, Strict::Array.member(AnyAttribute).default([])
      attribute :type, DataType.optional.default(nil)

      def self.identifier_for_key(key)
        (self.class.hash ^ key.hash).to_s(16)
      end

      def dup
        raise "no dup dum dum"
      end

      def clone
        raise "no clone dum dum"
      end
    end

    Dry::Types.register_class(PropertyDefinition)
  end
end
