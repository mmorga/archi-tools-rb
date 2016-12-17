# frozen_string_literal: true

module Archimate
  module Diff
    class ArchimateNodeReference
      using DataModel::DiffablePrimitive
      using DataModel::DiffableArray

      attr_reader :archimate_node

      def initialize(archimate_node)
        raise(
          TypeError,
          "archimate_node must be an ArchimateNode or Array, was #{archimate_node.class}"
        ) unless archimate_node.is_a?(DataModel::ArchimateNode) || archimate_node.is_a?(Array)
        @archimate_node = archimate_node
      end

      def ==(other)
        other.is_a?(self.class) &&
          archimate_node == other.archimate_node
      end

      def to_s
        value.to_s
      end

      def value
        @archimate_node
      end

      def array_insert_index(parent_in_to_model)
        idx = parent.find_index(value)
        while idx.positive?
          idx -= 1
          previous_value = parent[idx]
          to_index = parent_in_to_model.find_index(previous_value)
          if to_index
            idx = to_index + 1
            break
          end
        end
        idx
      end

      def insert(to_model)
        parent_in_to_model = lookup_parent_in_model(to_model)
        if parent_in_to_model.is_a?(Array)
          idx = array_insert_index(parent_in_to_model)
        else
          idx = parent.attribute_name(value)
        end
        parent_in_to_model.insert(idx, value)
      end

      def delete(to_model)
        parent_in_to_model = lookup_parent_in_model(to_model)
        if parent_in_to_model.is_a?(Array)
          parent_in_to_model.delete(parent.attribute_name(value), value)
        else
          parent_in_to_model.delete(parent.attribute_name(value), value)
        end
      end

      def change(to_model)
        insert(to_model)
      end

      def lookup_in_model(model)
        return nil if model.nil?
        raise TypeError unless model.is_a?(DataModel::Model)
        lookup_parent_in_model(model)[parent.attribute_name(value)]
      end

      def lookup_parent_in_model(model)
        Archimate.node_reference(parent).lookup_in_model(model)
      end

      def parent
        archimate_node.parent
      end

      def path(options = {})
        @archimate_node.path(options)
      end
    end
  end
end
