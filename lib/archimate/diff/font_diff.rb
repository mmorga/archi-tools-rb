# frozen_string_literal: true
module Archimate
  module Diff
    class FontDiff
      def diffs(context)
        context.diff(StringDiff.new, :name)
        context.diff(PrimitiveDiff.new, :size)
        context.diff(PrimitiveDiff.new, :style)
      end
    end
  end
end
