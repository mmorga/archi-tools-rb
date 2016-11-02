# frozen_string_literal: true
module Archimate
  module Diff
    class Conflicts
      class PathConflict
        attr_reader :associative

        def initialize(base_local_diffs, base_remote_diffs)
          @associative = false
          @base_local_diffs = base_local_diffs
          @base_remote_diffs = base_remote_diffs
        end

        def describe
          "Differences in one change set conflict with changes in other change set at the same path"
        end

        def filter1
        end

        def filter2
        end

        def conflicts
          @base_local_diffs.each_with_object([]) do |ldiff, cfx|
            conflicting_remote_diffs =
              @base_remote_diffs.select { |rdiff| ldiff.path == rdiff.path && ldiff != rdiff }.select do |rdiff|
                if !(ldiff.array? && rdiff.array?)
                  true
                else
                  case [ldiff, rdiff].map { |d| d.class.name.split('::').last }.sort
                  when %w(Change Change)
                    # TODO: if froms same and tos diff then conflict if froms diff then 2 sep changes else 1 change
                    ldiff.from == rdiff.from && ldiff.to != rdiff.to
                  when %w(Change Delete)
                    # TODO: if c.from d.from same then conflict else 1 c and 1 d
                    ldiff.from == rdiff.from
                  else
                    false
                  end
                end
              end.uniq

            cfx << Conflict.new(
              ldiff,
              conflicting_remote_diffs,
              "Conflicting changes"
            ) unless conflicting_remote_diffs.empty?
          end
        end
      end
    end
  end
end
