# frozen_string_literal: true
module Archimate
  module DataModel
    # A Property instance type declaring the reference to a Property definition and containing the Property value.
    class Property
      include Comparison

      model_attr :value # LangString.optional.default(nil)
      model_attr :property_definition # PropertyDefinition

      def initialize(property_definition:, value: nil)
        @property_definition = property_definition
        @value = value
      end

      def to_s
        "Property(key: #{property_definition.name}, value: #{value || 'no value'})"
      end

      def key
        property_definition.name
      end
    end
  end
end
