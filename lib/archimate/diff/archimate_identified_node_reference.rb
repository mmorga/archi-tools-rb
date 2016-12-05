# frozen_string_literal: true

module Archimate
  module Diff
    class ArchimateIdentifiedNodeReference < ArchimateNodeReference
      using DataModel::DiffableArray

      def initialize(archimate_node)
        super
      end

      def lookup_in_model(model)
        raise TypeError unless model.is_a?(DataModel::Model)
        # There can be only one Model so return the model argument if
        # this node reference is a Model. This escape is required in case
        # the Model this is being applied to has a different id than the
        # model of the attribute this reference refers to.
        return model if archimate_node.is_a?(DataModel::Model)
        model.lookup(@archimate_node.id)
      end

      def delete(to_model)
        lookup_parent_in_model(to_model).delete(@archimate_node.id, @archimate_node)
      end

      def insert(to_model)
        lookup_parent_in_model(to_model).insert(@archimate_node.parent.attribute_name(@archimate_node), @archimate_node)
      end

      def change(to_model)
        lookup_parent_in_model(to_model).insert(@archimate_node.parent.attribute_name(@archimate_node), @archimate_node)
      end

      def to_s
        @archimate_node.to_s
      end

      def value
        @archimate_node
      end
    end
  end
end
