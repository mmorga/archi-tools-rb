# frozen_string_literal: true
module Archimate
  module Diff
    class BoundsDiff
      def diffs(context)
        context.diff(FloatDiff.new, :x)
        context.diff(FloatDiff.new, :y)
        context.diff(FloatDiff.new, :width)
        context.diff(FloatDiff.new, :height)
      end
    end
  end
end
