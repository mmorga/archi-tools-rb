# frozen_string_literal: true
module Archimate
  module Diff
    class ElementDiff
      def diffs(context)
        context.diff(StringDiff.new, :id)
        context.diff(StringDiff.new, :type)
        context.diff(StringDiff.new, :label)
        context.diff(UnorderedListDiff.new, :documentation)
        context.diff(UnorderedListDiff.new, :properties)
      end
    end
  end
end
