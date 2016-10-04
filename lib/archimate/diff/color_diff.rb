# frozen_string_literal: true
module Archimate
  module Diff
    class ColorDiff
      def diffs(context)
        context.diff(PrimitiveDiff.new, :r)
        context.diff(PrimitiveDiff.new, :g)
        context.diff(PrimitiveDiff.new, :b)
        context.diff(PrimitiveDiff.new, :a)
      end
    end
  end
end
