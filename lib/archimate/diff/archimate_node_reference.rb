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

      def lookup_in_model(model)
        recurse_lookup_in_model(archimate_node, model)
      end

      def recurse_lookup_in_model(node, model)
        raise TypeError, "node argument must be ArchimateNode or Array, was a #{node.class}" unless node.is_a?(Array) || node.is_a?(DataModel::ArchimateNode)
        raise TypeError, "model argument must be a Model, was a #{model.class}" unless model.is_a?(DataModel::Model)
        if node.is_a?(DataModel::Model)
          return model
        elsif node.is_a?(DataModel::IdentifiedNode)
          return model.lookup(node.id)
        else
          recurse_lookup_in_model(node.parent, model)[node.parent_attribute_name]
        end
      end

      def lookup_parent_in_model(model)
        recurse_lookup_in_model(parent, model)
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
