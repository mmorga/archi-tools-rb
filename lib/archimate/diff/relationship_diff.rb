# frozen_string_literal: true
module Archimate
  module Diff
    class RelationshipDiff
      def diffs(context)
        context.diff(StringDiff.new, :id)
        context.diff(StringDiff.new, :type)
        context.diff(StringDiff.new, :name)
        context.diff(StringDiff.new, :source)
        context.diff(StringDiff.new, :target)
        context.diff(UnorderedListDiff.new, :documentation)
        context.diff(UnorderedListDiff.new, :properties)
      end
    end
  end
end
