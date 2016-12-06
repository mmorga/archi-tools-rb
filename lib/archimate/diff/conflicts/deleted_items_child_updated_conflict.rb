# frozen_string_literal: true
module Archimate
  module Diff
    class Conflicts
      class DeletedItemsChildUpdatedConflict < BaseConflict
        def describe
          "Deleted items in one change set have children that are inserted or changed in the other change set"
        end

        def filter1
          ->(diff) { diff.delete? }
        end

        def filter2
          ->(diff) { !diff.delete? }
        end

        # TODO: This is simple, but might be slow.
        def diff_conflicts(diff1, diff2)
          diff2.path.start_with?(diff1.path)
        end
      end
    end
  end
end
