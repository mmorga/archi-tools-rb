# frozen_string_literal: true

module Archimate
  module DataModel
    class SchemaInfo < ArchimateNode
      using DiffablePrimitive

      attribute :schema, Strict::String.optional
      attribute :schemaversion, Strict::String.optional

      def to_s
        "#{type.light_black}[#{schema} #{schemaversion}]"
      end
    end
    Dry::Types.register_class(SchemaInfo)
  end
end
