# frozen_string_literal: true

module Archimate
  module Diff
    class ArchimateNodeAttributeReference < ArchimateNodeReference
      attr_reader :attribute

      def initialize(archimate_node, attribute)
        unless archimate_node.is_a?(DataModel::ArchimateNode)
          raise(
            TypeError,
            "archimate_node must be an ArchimateNode, was #{archimate_node.class}"
          )
        end
        unless attribute.is_a?(Symbol)
          raise(
            TypeError,
            "Node #{archimate_node.class} attribute must be a sym, was a #{attribute.class} value #{attribute.inspect}"
          )
        end
        unless archimate_node.class.schema.keys.include?(attribute)
          raise(
            ArgumentError,
            "Attribute #{attribute} invalid for class #{archimate_node.class}"
          )
        end
        super(archimate_node)
        @attribute = attribute
      end

      def ==(other)
        super && attribute == other.attribute
      end

      def lookup_in_model(model)
        recurse_lookup_in_model(archimate_node, model)[attribute]
      end

      def to_s
        attribute.to_s
      end

      def value
        archimate_node[attribute]
      end

      def path(options = {})
        @node_attribute_ref_path ||= [
          super, @attribute
        ].map(&:to_s).reject(&:empty?).join("/")
      end

      def insert(to_model)
        lookup_parent_in_model(to_model).set(attribute, value)
      end

      def delete(to_model)
        lookup_parent_in_model(to_model).delete(attribute)
      end

      def change(to_model, _from_value)
        lookup_parent_in_model(to_model).set(attribute, value)
      end

      def move(_to_model)
        raise "Move is not valid for ArchimateNodes"
      end
    end
  end
end
