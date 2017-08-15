# frozen_string_literal: true

module Archimate
  module Diff
    class ArchimateNodeReference
      attr_reader :archimate_node

      # There should be only a few things that are valid here:
      # 1. An archimate node and a attribute name sym
      # 2. An array and index
      # Produces a NodeReference instance for the given parameters
      def self.for_node(node, child_node)
        case node
        when DataModel::ArchimateNode
          ArchimateNodeAttributeReference.new(node, child_node)
        when Array
          ArchimateArrayReference.new(node, child_node)
        else
          raise TypeError, "Node references need to be either an ArchimateNode or an Array"
        end
      end

      def initialize(archimate_node)
        unless archimate_node.is_a?(DataModel::ArchimateNode) || archimate_node.is_a?(Array)
          raise(
            TypeError,
            "archimate_node must be an ArchimateNode or Array, was #{archimate_node.class}"
          )
        end
        raise "new WTF? parent at path #{archimate_node.path} is a #{archimate_node.class} but isn't assigned a model" if archimate_node.in_model.nil? && !archimate_node.is_a?(DataModel::Model)
        @archimate_node = archimate_node
      end

      def ==(other)
        other.is_a?(self.class) &&
          value == other.value
      end

      def to_s
        value.to_s
      end

      def lookup_in_model(model)
        recurse_lookup_in_model(archimate_node, model)
      end

      def recurse_lookup_in_model(node, model)
        return nil if node.nil?
        raise TypeError, "node argument must be ArchimateNode or Array, was a #{node.class}" unless node.is_a?(Array) || node.is_a?(DataModel::ArchimateNode)
        raise TypeError, "model argument must be a Model, was a #{model.class}" unless model.is_a?(DataModel::Model)
        if node.is_a?(DataModel::Model)
          return model
        elsif node.is_a?(DataModel::Referenceable)
          return model.lookup(node.id)
        else
          node_parent_in_model = recurse_lookup_in_model(node.parent, model)
          node_parent_in_model[node.parent_attribute_name] unless node_parent_in_model.nil?
        end
      end

      def lookup_parent_in_model(model)
        raise "WTF? parent at path #{path} is a #{parent.class} but isn't assigned a model" if parent.in_model.nil? && !parent.is_a?(DataModel::Model)
        result = recurse_lookup_in_model(parent, model)
        $stderr.puts "Unable to lookup parent with path #{path}" if result.nil?
        result
      end

      def parent
        archimate_node
      end

      def path(options = {})
        @node_ref_path ||= archimate_node.path(options)
      end
    end
  end
end
