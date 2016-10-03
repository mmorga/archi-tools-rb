# frozen_string_literal: true
module Archimate
  module Diff
    class FontDiff
      def diffs(context)
        context.diff(StringDiff.new, :name)
        context.diff(IntDiff.new, :size)
        context.diff(IntDiff.new, :style)
      end
    end
  end
end
