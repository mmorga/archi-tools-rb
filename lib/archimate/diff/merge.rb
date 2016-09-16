# frozen_string_literal: true
module Archimate
  module Diff
    # So it could be that if an item is deleted from 1 side
    # then it's actually the result of a de-duplication pass.
    # If so, then we could get good results by de-duping the
    # new side and comparing the results.
    class Merge
      def three_way(base, local, remote)
        base_local_diffs = Archimate.diff(base, local)
        base_remote_diffs = Archimate.diff(base, remote)

        result = base.dup
        base_local_diffs.each do |diff|
          result.apply_diff(diff) if diff.kind == :insert
        end

        base_remote_diffs.each do |diff|
          result.apply_diff(diff) if diff.kind == :insert
        end

        result
      end
    end
  end
end
