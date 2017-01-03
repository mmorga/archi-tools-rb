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
        puts path
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

      # def lookup_in_model(model)
      #   lookup_parent_in_model(model)[parent.attribute_name(archimate_node)]
      # end
      def lookup_in_model(model)
        return nil if model.nil?
        raise TypeError unless model.is_a?(DataModel::Model)
        mp = lookup_parent_in_model(model)
        mp[mp.find_index(value)]
      end


      def attribute_index
        array_index
      end

      def lookup_parent_in_model(model)
        return nil if model.nil?
        raise TypeError unless model.is_a?(DataModel::Model)
        ArchimateNodeAttributeReference.new(
          archimate_node.parent,
          archimate_node.parent.attribute_name(archimate_node)
        ).lookup_in_model(model)
      end

      def insert(to_model)
        lookup_in_model(to_model).insert(array_index, value)
      end

      def delete(to_model)
        lookup_in_model(to_model).delete(array_index, value)
      end

      def change(to_model)
        lookup_in_model(to_model)[array_index] = value
      end

      def move(to_model)
        ary = lookup_in_model(to_model)
        raise "Implement me"
      end
    end
  end
end
