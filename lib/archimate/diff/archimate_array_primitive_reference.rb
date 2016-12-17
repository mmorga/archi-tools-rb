# frozen_string_literal: true

module Archimate
  module Diff
    class ArchimateArrayPrimitiveReference < ArchimateNodeReference
      using DataModel::DiffablePrimitive

      attr_reader :array_index

      def initialize(array, array_index)
        raise(
          TypeError,
          "array argument must be an Array, was #{array.class}"
        ) unless array.is_a?(Array)
        raise(
          TypeError,
          "array_index argument must be a Fixnum, was #{array_index.class} #{array_index.inspect}"
        ) unless array_index.is_a?(Fixnum)
        raise(
          ArgumentError,
          "array_index argument a valid index for array #{array_index.inspect}"
        ) unless array_index >= 0 && array_index < array.size
        raise(
          TypeError,
          "expected reference to be a primitive value, was #{array[array_index].class}"
        ) unless array[array_index].primitive?
        super(array)
        @array_index = array_index
      end

      def ==(other)
        super && array_index == other.array_index
      end

      def value
        archimate_node[array_index]
      end

      def parent
        archimate_node
      end

      def lookup_in_model(model)
        raise TypeError unless model.is_a?(DataModel::Model)
        parent_in_model = Archimate.node_reference(parent).lookup_in_model(model)
        parent_in_model[parent_in_model.find_index(value)]
      end
    end
  end
end
