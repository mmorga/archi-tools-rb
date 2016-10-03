# frozen_string_literal: true
module Archimate
  module Diff
    class SourceConnectionDiff
      def diffs(context)
        context.diff(StringDiff.new, :id)
        context.diff(StringDiff.new, :type)
        context.diff(StringDiff.new, :source)
        context.diff(StringDiff.new, :target)
        context.diff(StringDiff.new, :relationship)
        context.diff(StringDiff.new, :name)
        context.diff(UnorderedListDiff.new(BendpointDiff), :bendpoints)
        context.diff(UnorderedListDiff.new, :documentation)
        context.diff(UnorderedListDiff.new, :properties)
        context.diff(StyleDiff.new, :style)
      end
    end
  end
end
