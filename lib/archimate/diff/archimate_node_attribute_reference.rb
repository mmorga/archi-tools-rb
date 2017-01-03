# frozen_string_literal: true

module Archimate
  module Diff
    class ArchimateNodeAttributeReference < ArchimateNodeReference
      attr_reader :attribute

      def initialize(archimate_node, attribute)
        raise(
          TypeError,
          "archimate_node must be an ArchimateNode, was #{archimate_node.class}"
        ) unless archimate_node.is_a?(DataModel::ArchimateNode)
        raise(
          TypeError,
          "Node #{archimate_node.class} attribute should be a sym or string, was a #{attribute.class} value #{attribute.inspect}"
        ) unless attribute.is_a?(String) || attribute.is_a?(Symbol)
        raise(
          ArgumentError,
          "Attribute #{attribute} invalid for class #{archimate_node.class}"
        ) unless archimate_node.class.schema.keys.include?(attribute.to_sym)
        super(archimate_node)
        @attribute = attribute.to_s
      end

      def ==(other)
        super && attribute == other.attribute
      end

      def lookup_in_model(model)
        recurse_lookup_in_model(archimate_node, model)[attribute]
      end

      def attribute_index
        attribute
      end

      def to_s
        value.to_s
      end

      def value
        @archimate_node[@attribute]
      end

      def path(options = {})
        [super, @attribute].map(&:to_s).reject(&:empty?).join("/")
      end
    end
  end
end
