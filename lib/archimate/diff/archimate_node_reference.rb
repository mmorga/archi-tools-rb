# frozen_string_literal: true

module Archimate
  module Diff
    class ArchimateNodeReference
      using DataModel::DiffablePrimitive
      using DataModel::DiffableArray

      attr_reader :archimate_node

      # There should be only a few things that are valid here:
      # 1. An archimate node and a attribute name sym
      # 2. An array and index
      # Produces a NodeReference instance for the given parameters
      def self.for_node(node, child_node)
        case node
        when DataModel::ArchimateNode
          ArchimateNodeAttributeReference.new(node, child_node)
        when Array, DataModel::BaseArray
          ArchimateArrayReference.new(node, child_node)
        else
          raise TypeError, "Node references need to be either an ArchimateNode or an Array"
        end
        # case node
        # when DataModel::IdentifiedNode
        #   if child_node.nil?
        #     ArchimateIdentifiedNodeReference.new(node)
        #   else
        #     ArchimateNodeAttributeReference.new(node, child_node)
        #   end
        # when Array, DataModel::BaseArray
        #   return ArchimateNodeReference.new(node) if child_node.nil?
        #   raise(
        #     TypeError,
        #     "child_node must be a Fixnum if node is an Array"
        #   ) unless child_node.is_a?(Fixnum)
        #   raise(
        #     ArgumentError,
        #     "child_node index is out of range of node array"
        #   ) unless child_node >= 0 && child_node < node.size
        #   child_value = node[child_node]
        #   case child_value
        #   when DataModel::IdentifiedNode
        #     ArchimateIdentifiedNodeReference.new(child_value)
        #   when DataModel::ArchimateNode
        #     ArchimateNodeReference.new(child_value)
        #   else
        #     ArchimateArrayPrimitiveReference.new(node, child_node)
        #   end
        # when DataModel::ArchimateNode
        #   if child_node.nil?
        #     ArchimateNodeReference.new(node)
        #   else
        #     ArchimateNodeAttributeReference.new(node, child_node)
        #   end
        # else
        #   raise TypeError, "Expected node #{node.class} to be ArchimateNode, IdentifiedNode, or Array"
        # end
      end

      def initialize(archimate_node)
        raise(
          TypeError,
          "archimate_node must be an ArchimateNode or Array, was #{archimate_node.class}"
        ) unless archimate_node.is_a?(DataModel::ArchimateNode) || archimate_node.is_a?(Array) || archimate_node.is_a?(DataModel::BaseArray)
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
        puts "inserting idx #{idx.class} #{idx.inspect} into #{parent_in_to_model.class}"
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

      def move(to_model)
        raise "Implement me"
      end

      def lookup_in_model(model)
        recurse_lookup_in_model(archimate_node, model)
      end

      def attribute_index
        raise "Not implemented"
      end

      def recurse_lookup_in_model(node, model)
        return nil if model.nil?
        raise TypeError unless model.is_a?(DataModel::Model)
        return model if archimate_node.is_a?(DataModel::Model)
        return model.lookup(node.id) if node.is_a?(DataModel::IdentifiedNode)
        recurse_lookup_in_model(node.parent, model)[node.parent.attribute_name(value)]
      end

      def lookup_parent_in_model(model)
        recurse_lookup_in_model(archimate_node.parent, model)
      end

      def parent
        archimate_node
      end

      def path(options = {})
        @archimate_node.path(options)
      end
    end
  end
end
