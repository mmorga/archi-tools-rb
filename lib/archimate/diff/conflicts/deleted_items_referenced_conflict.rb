# frozen_string_literal: true
module Archimate
  module Diff
    class Conflicts
      class DeletedItemsReferencedConflict < BaseConflict
        using DataModel::DiffableArray
        using DataModel::DiffablePrimitive

        def describe
          "Deleted items in one change set are referenced in the other change set"
        end

        def filter1
          ->(diff) { diff.delete? }
        end

        def filter2
          ->(diff) { !diff.delete? }
        end

        # TODO: This is simple, but might be slow. If it is, then override
        # the conflicts method to prevent calculating identified_nodes
        # and referenced_identified_nodes methods
        def diff_conflicts(diff1, diff2)
          diff1.target.value.identified_nodes & diff2.target.value.referenced_identified_nodes
        end
      end
    end
  end
end
