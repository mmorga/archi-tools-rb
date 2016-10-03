# frozen_string_literal: true
module Archimate
  module Diff
    class ColorDiff
      def diffs(context)
        context.diff(IntDiff.new, :r)
        context.diff(IntDiff.new, :g)
        context.diff(IntDiff.new, :b)
        context.diff(IntDiff.new, :a)
      end
    end
  end
end
