# frozen_string_literal: true

module Archimate
  module Diff
    class ArchimateReferenceableReference < ArchimateNodeReference
      def initialize(archimate_node)
        unless archimate_node.is_a?(DataModel::Referenceable)
          raise(
            TypeError,
            "archimate_node is a #{archimate_node.class}, Referenceable was expected"
          )
        end
        super
      end

      def lookup_in_model(model)
        raise TypeError unless model.is_a?(DataModel::Model)
        # There can be only one Model so return the model argument if
        # this node reference is a Model. This escape is required in case
        # the Model this is being applied to has a different id than the
        # model of the attribute this reference refers to.
        return model if archimate_node.is_a?(DataModel::Model)
        model.lookup(archimate_node.id)
      end

      def to_s
        archimate_node.to_s
      end

      def value
        archimate_node
      end

      def parent
        archimate_node.parent
      end
    end
  end
end
