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
          "array_index argument must be a Integer, was #{array_index.class} #{array_index.inspect}"
        ) unless array_index.is_a?(Integer)
        raise(
          ArgumentError,
          "array_index argument a valid index for array #{array_index.inspect}"
        ) unless array_index >= 0 && array_index < array.size
        super(array)
        @array_index = array_index
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

      # For inserts - we can't be sure of what is available (without an expensive sort)
      # So lookup the first previous value that exists in to_model and insert it after that
      # value instead of a fixed index.
      def find_insert_index_in_ary(ary)
        return -1 if array_index.zero?
        my_idx = (array_index - 1).downto(0).find(-1) do |idx|
          ary.smart_include?(archimate_node[idx])
        end
        ary.smart_find(archimate_node[my_idx])
      end

      def insert(to_model)
        ary_in_model = lookup_parent_in_model(to_model)
        insert_idx = find_insert_index_in_ary(ary_in_model) + 1
        to_model.register(value, ary_in_model)
        ary_in_model.insert(insert_idx, value)
      end

      def delete(to_model)
        ary_in_model = lookup_parent_in_model(to_model)
        if ary_in_model.nil?
          $stderr.puts "lookup parent in model failed for path #{path}"
          return nil
        end
        idx = ary_in_model.smart_find(value)
        if idx
          to_model.deregister(ary_in_model[idx])
          ary_in_model.delete_at(idx)
        else
          $stderr.puts "Oh crap - couldn't find item #{value.inspect} to delete in to_model"
        end
      end

      def change(to_model, from_value)
        ary_in_model = lookup_parent_in_model(to_model)
        idx = ary_in_model.smart_find(from_value)
        to_model.deregister(ary_in_model[idx])
        to_model.register(value, ary_in_model)
        ary_in_model[idx] = value
      end

      def move(to_model, from_ref)
        ary_in_model = lookup_parent_in_model(to_model)
        insert_idx = parent.previous_item_index(ary_in_model, value) + 1
        current_idx = ary_in_model.smart_find(value)
        deleted_value = ary_in_model.delete_at(current_idx)
        ary_in_model.insert(
          insert_idx,
          deleted_value
        )
      end
    end
  end
end
