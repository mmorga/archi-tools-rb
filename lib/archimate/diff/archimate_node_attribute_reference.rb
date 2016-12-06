# frozen_string_literal: true

module Archimate
  module Diff
    class ArchimateNodeAttributeReference < ArchimateNodeReference
      attr_reader :attribute

      def initialize(archimate_node, attribute)
        raise TypeError, "Attribute should be a sym or string" unless attribute.is_a?(String) || attribute.is_a?(Symbol)
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
        raise TypeError unless model.is_a?(DataModel::Model)
        Archimate.node_reference(archimate_node).lookup_in_model(model)[attribute]
      end

      def parent
        @archimate_node
      end

      def to_s
        @attribute
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
