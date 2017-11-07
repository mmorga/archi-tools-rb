# frozen_string_literal: true

module Archimate
  module DataModel
    # A Property instance type declaring the reference to a [PropertyDefinition]
    # and containing the property value.
    class Property
      include Comparison

      # @!attribute [r] value
      # @return [LangString, NilClass] value of the property, default +nil+
      model_attr :value, default: nil
      # @!attribute [rw] property_definition
      # @return [PropertyDefinition] property definition of the property
      model_attr :property_definition, writable: true

      def to_s
        "Property(key: #{property_definition.name}, value: #{value || 'no value'})"
      end

      def key
        property_definition.name
      end
    end
  end
end
