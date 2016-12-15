# frozen_string_literal: true
module Archimate
  module Diff
    class Delete < Difference
      using DataModel::DiffablePrimitive
      using DataModel::DiffableArray

      # Create a new Delete difference
      #
      # @param target [ArchimateNodeReference] Element that was deleted
      def initialize(target)
        super
      end

      def to_s
        # Note - the explicit to_s is required to access the DiffableArray
        #        implementation if the parent is an Array.
        "#{diff_type} #{target} from #{target.parent.to_s}"
      end

      def apply(el)
        target.delete(el)
        el
      end

      def delete?
        true
      end

      def kind
        "Delete"
      end

      private

      def diff_type
        HighLine.color('DELETE:', :delete)
      end
    end
  end
end
