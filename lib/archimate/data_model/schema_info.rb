# frozen_string_literal: true

module Archimate
  module DataModel
    class SchemaInfo < Dry::Struct
      # specifies constructor style for Dry::Struct
      constructor_type :strict_with_defaults

      # using DiffablePrimitive

      attribute :schema, Strict::String.optional
      attribute :schemaversion, Strict::String.optional
      attribute :elements, Strict::Array.member(AnyElement).default([])

      def to_s
        "#{type.light_black}[#{schema} #{schemaversion}]"
      end
    end
    Dry::Types.register_class(SchemaInfo)
  end
end
