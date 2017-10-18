# frozen_string_literal: true

module Archimate
  module DataModel
    # Something that can be referenced in the model.
    class Referenceable < ArchimateNode
      private

      def find_my_index
        id
      end

      # name isn't merged
      def merge(node)
        documentation.concat(node.documentation)
        properties.concat(node.properties)
      end
    end
  end
end
