# frozen_string_literal: true
module Archimate
  module Diff
    class StyleDiff
      def diffs(context)
        context.diff(PrimitiveDiff.new, :text_alignment)
        context.diff(ColorDiff.new, :fill_color)
        context.diff(ColorDiff.new, :line_color)
        context.diff(ColorDiff.new, :font_color)
        context.diff(PrimitiveDiff.new, :line_width)
        context.diff(FontDiff.new, :font)
      end
    end
  end
end
