# frozen_string_literal: true
module Archimate
  module Diff
    # So it could be that if an item is deleted from 1 side
    # then it's actually the result of a de-duplication pass.
    # If so, then we could get good results by de-duping the
    # new side and comparing the results.
    class Merge
      def three_way(base, local, remote)
        apply_diffs(Archimate.diff(base, remote),
          apply_diffs(Archimate.diff(base, local), base.with)
        )
      end

      def apply_diffs(diffs, model)
        diffs.select(&:insert?).inject(model) do |m, diff|
          m.apply_diff(diff)
        end
      end
    end
  end
end
