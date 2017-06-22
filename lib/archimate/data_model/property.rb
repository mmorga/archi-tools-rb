# frozen_string_literal: true
module Archimate
  module DataModel
    # A Property instance type declaring the reference to a Property definition and containing the Property value.
    class Property < ArchimateNode
      attribute :values, Strict::Array.member(LangString).default([]) # .constrained(min_size: 1)
      attribute :property_definition_id, Identifier

      def to_s
        "Property(key: #{property_definition.name}, value: #{value || 'no value'})"
      end

      def key
        property_definition&.name
      end

      def value
        values.first
      end

      def property_definition
        in_model&.lookup(property_definition_id)
      end
    end

    Dry::Types.register_class(Property)
    PropertiesList = Strict::Array.member(Property).default([])
  end
end
