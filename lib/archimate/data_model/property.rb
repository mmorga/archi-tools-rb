# frozen_string_literal: true
module Archimate
  module DataModel
    # A Property instance type declaring the reference to a Property definition and containing the Property value.
    class Property < Dry::Struct
      # specifies constructor style for Dry::Struct
      constructor_type :strict_with_defaults

      attribute :value, LangString.optional.default(nil)
      attribute :property_definition, PropertyDefinition

      def to_s
        "Property(key: #{property_definition.name}, value: #{value || 'no value'})"
      end

      def key
        property_definition.name
      end
    end

    Dry::Types.register_class(Property)
  end
end
