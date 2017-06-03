# frozen_string_literal: true
module Archimate
  module Diff
    class Conflicts
      class PathConflict < BaseConflict
        def initialize(base_local_diffs, base_remote_diffs)
          super
          @associative = true
        end

        def describe
          "Differences in one change set conflict with changes in other change set at the same path"
        end

        def diff_conflicts(diff1, diff2)
          same_path_but_diff(diff1, diff2) && in_conflict?(diff1, diff2)
        end

        private

        def same_path_but_diff(a, b)
          a.path == b.path && a != b
        end

        # I'm in conflict if:
        # 1. ld and rd are both changes to the same path (but not the same change)
        # 2. one is a change, the other a delete and changed_from is the same
        # 3. both are inserts of the different identifyable nodes with the same id
        #
        # If I'm not an identifyable node and my parent is an array, then two inserts are ok
        def in_conflict?(local_diff, remote_diff)
          return true if
            local_diff.target.parent.is_a?(Array) &&
            local_diff.target.value.is_a?(DataModel::IdentifiedNode) &&
            local_diff.target.value.id == remote_diff.target.value.id &&
            local_diff != remote_diff

          case [local_diff, remote_diff].map { |d| d.class.name.split('::').last }.sort
          when %w(Change Change)
            local_diff.changed_from.value == remote_diff.changed_from.value &&
              local_diff.target.value != remote_diff.target.value
          when %w(Change Delete)
            true
          else
            false
          end
        end
      end
    end
  end
end
