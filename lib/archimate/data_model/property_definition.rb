# frozen_string_literal: true

module Archimate
  module DataModel
    # A Property definition type containing its unique identifier, name, and data type.
    class PropertyDefinition < NamedReferenceable
      attribute :value_type, DataType

      def self.identifier_for_key(key)
        (self.class.hash ^ key.hash).to_s(16)
      end
    end

    Dry::Types.register_class(PropertyDefinition)
  end
end
