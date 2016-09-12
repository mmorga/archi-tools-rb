# frozen_string_literal: true
module Archimate
  module Diff
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
