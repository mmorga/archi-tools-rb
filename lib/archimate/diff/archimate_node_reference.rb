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

      def reference_class
        @archimate_node.class
      end

      def to_s
        value.to_s
      end

      def value
        @archimate_node
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

      def array?
        item_type?(Array)
      end

      # Returns true if this diff is for a diagram (not a part within a diagram)
      def diagram?
        item_type?(DataModel::Diagram)
      end

      def in_diagram?
        in_item_type?(DataModel::Diagram)
      end

      def element?
        item_type?(DataModel::Element)
      end

      def in_element?
        in_item_type?(DataModel::Element)
      end

      def in_folder?
        in_item_type?(DataModel::Folder)
      end

      def relationship?
        item_type?(DataModel::Relationship)
      end

      def in_relationship?
        in_item_type?(DataModel::Relationship)
      end

      def item_type?(klass)
        value.is_a?(klass)
      end

      def in_item_type?(klass)
        if value.primitive?
          (@archimate_node.ancestors.map(&:class) + [self.class]).include?(klass)
        else
          value.ancestors.map(&:class).include?(klass)
        end
      end
    end
  end
end
