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

        def in_conflict?(local_diff, remote_diff)
          if !(local_diff.array? && remote_diff.array?)
            true
          else
            case [local_diff, remote_diff].map { |d| d.class.name.split('::').last }.sort
            when %w(Change Change)
              # TODO: if froms same and tos diff then conflict if froms diff then 2 sep changes else 1 change
              local_diff.from == remote_diff.from && local_diff.to != remote_diff.to
            when %w(Change Delete)
              # TODO: if c.from d.from same then conflict else 1 c and 1 d
              local_diff.from == remote_diff.from
            else
              false
            end
          end
        end

        # def conflicts
        #   @base_local_diffs.each_with_object([]) do |ldiff, cfx|
        #     conflicting_remote_diffs =
        #       @base_remote_diffs.select { |rdiff| ldiff.path == rdiff.path && ldiff != rdiff }.select do |rdiff|
        #         if !(ldiff.array? && rdiff.array?)
        #           true
        #         else
        #           case [ldiff, rdiff].map { |d| d.class.name.split('::').last }.sort
        #           when %w(Change Change)
        #             # TODO: if froms same and tos diff then conflict if froms diff then 2 sep changes else 1 change
        #             ldiff.from == rdiff.from && ldiff.to != rdiff.to
        #           when %w(Change Delete)
        #             # TODO: if c.from d.from same then conflict else 1 c and 1 d
        #             ldiff.from == rdiff.from
        #           else
        #             false
        #           end
        #         end
        #       end.uniq

        #     cfx << Conflict.new(
        #       ldiff,
        #       conflicting_remote_diffs,
        #       "Conflicting changes"
        #     ) unless conflicting_remote_diffs.empty?
        #   end
        # end
      end
    end
  end
end
