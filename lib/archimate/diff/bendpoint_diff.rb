# frozen_string_literal: true
module Archimate
  module Diff
    class BendpointDiff
      def diffs(context)
        context.diff(FloatDiff.new, :start_x)
        context.diff(FloatDiff.new, :start_y)
        context.diff(FloatDiff.new, :end_x)
        context.diff(FloatDiff.new, :end_y)
      end
    end
  end
end
