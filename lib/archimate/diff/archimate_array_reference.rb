# frozen_string_literal: true

module Archimate
  module Diff
    class ArchimateArrayReference < ArchimateNodeReference
      using DataModel::DiffableArray
      using DataModel::DiffablePrimitive

      attr_reader :array_index

      def initialize(array, array_index)
        raise(
          TypeError,
          "array argument must be an Array, was #{array.class}"
        ) unless array.is_a?(Array) || array.is_a?(DataModel::BaseArray)
        raise(
          TypeError,
          "array_index argument must be a Fixnum, was #{array_index.class} #{array_index.inspect}"
        ) unless array_index.is_a?(Fixnum)
        raise(
          ArgumentError,
          "array_index argument a valid index for array #{array_index.inspect}"
        ) unless array_index >= 0 && array_index < array.size
        super(array)
        @array_index = array_index
      end

      def ==(other)
        super && array_index == other.array_index
      end

      def value
        archimate_node[array_index]
      end

      def to_s
        value.to_s
      end

      def lookup_in_model(model)
        result = lookup_parent_in_model(model)
        raise TypeError, "result was #{result.class} expected Array" unless result.is_a?(Array)
        result[array_index]
      end

      def path(options = {})
        [
          super,
          case value
          when DataModel::IdentifiedNode
            value.id
          else
            array_index
          end
        ].map(&:to_s).reject(&:empty?).join("/")
      end

      def insert(to_model)
        lookup_parent_in_model(to_model).insert(array_index, value)
      end

      def delete(to_model)
        lookup_parent_in_model(to_model).delete(array_index, value)
      end

      def change(to_model)
        lookup_parent_in_model(to_model)[array_index] = value
      end

      def move(to_model)
        lookup_parent_in_model(to_model).move(array_index, value)
      end
    end
  end
end
