# frozen_string_literal: true
module Archimate
  module DataModel
    class Property < NonIdentifiedNode
      attribute :key, Strict::String
      attribute :value, Strict::String.optional
      attribute :lang, Strict::String.default("en")

      def clone
        Property.new(
          key: key.clone,
          value: value&.clone,
          lang: lang&.clone
        )
      end

      def to_s
        "Property(key: #{key}, value: #{value || 'no value'})"
      end

      def property_id
        in_model.property_def_id(key)
      end
    end

    Dry::Types.register_class(Property)
    PropertiesList = Strict::Array.member(Property).default([])
  end
end
