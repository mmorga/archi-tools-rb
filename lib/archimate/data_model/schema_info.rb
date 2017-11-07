# frozen_string_literal: true

module Archimate
  module DataModel
    class SchemaInfo
      include Comparison

      # @!attribute [r] schema
      # @return [String, NilClass]
      model_attr :schema, default: nil
      # @!attribute [r] schemaversion
      # @return [String, NilClass]
      model_attr :schemaversion, default: nil
      # @!attribute [r] elements
      # @return [Array<AnyElement>]
      model_attr :elements, default: []

      def to_s
        "#{type.light_black}[#{schema} #{schemaversion}]"
      end
    end
  end
end
