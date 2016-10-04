# frozen_string_literal: true
module Archimate
  module Diff
    class DiagramDiff
      def diffs(context)
        context.diff(StringDiff.new, :id)
        context.diff(StringDiff.new, :name)
        context.diff(StringDiff.new, :viewpoint)
        context.diff(UnorderedListDiff.new, :documentation)
        context.diff(UnorderedListDiff.new, :properties)
        context.diff(IdHashDiff.new(ChildDiff), :children)
        context.diff(IdHashDiff.new(StringDiff), :element_references)
        context.diff(PrimitiveDiff.new, :connection_router_type)
        context.diff(StringDiff.new, :type)
      end
    end
  end
end
