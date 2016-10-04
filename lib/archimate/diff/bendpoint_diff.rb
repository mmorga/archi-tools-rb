# frozen_string_literal: true
module Archimate
  module Diff
    class BendpointDiff
      def diffs(context)
        context.diff(PrimitiveDiff.new, :start_x)
        context.diff(PrimitiveDiff.new, :start_y)
        context.diff(PrimitiveDiff.new, :end_x)
        context.diff(PrimitiveDiff.new, :end_y)
      end
    end
  end
end
