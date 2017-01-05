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
          da1 = diff1.path.split("/")
          da2 = diff2.path.split("/")

          cmp_size = [da1, da2].map(&:size).min - 1
          return false if da2.size == cmp_size + 1
          da1[0..cmp_size] == da2[0..cmp_size]
        end
      end
    end
  end
end
