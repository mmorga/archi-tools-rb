# frozen_string_literal: true
module Archimate
  module Diff
    class ChildDiff
      def diffs(context)
        context.diff(StringDiff.new, :id)
        context.diff(StringDiff.new, :type)
        context.diff(StringDiff.new, :model)
        context.diff(StringDiff.new, :name)
        context.diff(StringDiff.new, :target_connections)
        context.diff(StringDiff.new, :archimate_element)
        context.diff(BoundsDiff.new, :bounds)
        context.diff(IdHashDiff.new(ChildDiff), :children)
        context.diff(UnorderedListDiff.new, :source_connections)
        context.diff(UnorderedListDiff.new, :documentation)
        context.diff(UnorderedListDiff.new, :properties)
        context.diff(StyleDiff.new, :style)
      end
    end
  end
end
