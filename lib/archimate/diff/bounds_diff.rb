# frozen_string_literal: true
module Archimate
  module Diff
    class BoundsDiff
      def diffs(context)
        context.diff(PrimitiveDiff.new, :x)
        context.diff(PrimitiveDiff.new, :y)
        context.diff(PrimitiveDiff.new, :width)
        context.diff(PrimitiveDiff.new, :height)
      end
    end
  end
end
