# frozen_string_literal: true

module Archimate
  module Diff
    class ArchimateNodeReference
      using DataModel::DiffablePrimitive
      using DataModel::DiffableArray

      attr_reader :archimate_node

      def initialize(archimate_node)
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

      def insert(to_model)
        lookup_parent_in_model(to_model).insert(parent.attribute_name(value), value)
      end

      def delete(to_model)
        lookup_parent_in_model(to_model).delete(parent.attribute_name(value), value)
      end

      def change(to_model)
        lookup_parent_in_model(to_model).insert(parent.attribute_name(value), value)
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
