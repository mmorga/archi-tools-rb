# frozen_string_literal: true

module Archimate
  module Diff
    class ArchimateArrayPrimitiveReference < ArchimateNodeReference
      using DataModel::DiffablePrimitive

      attr_reader :primitive

      def initialize(ary, primitive)
        raise TypeError unless ary.is_a?(Array)
        raise TypeError unless primitive.primitive?
        super(ary)
        @primitive = primitive
      end

      def ==(other)
        super && primitive == other.primitive
      end

      def value
        primitive
      end

      def parent
        archimate_node
      end

      def lookup_in_model(model)
        raise TypeError unless model.is_a?(DataModel::Model)
        parent_in_model = Archimate.node_reference(parent).lookup_in_model(model)
        parent_in_model[parent_in_model.find_index(primitive)] # [parent_in_model.attribute_name(self)]
      end
    end
  end
end
