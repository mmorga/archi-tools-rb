# frozen_string_literal: true
module Archimate
  module Diff
    class ModelDiff
      def diffs(context)
        context.diff(StringDiff.new, :id)
        context.diff(StringDiff.new, :name)
        context.diff(UnorderedListDiff.new, :documentation)
        context.diff(UnorderedListDiff.new, :properties)
        context.diff(IdHashDiff.new(ElementDiff), :elements)
        context.diff(IdHashDiff.new(RelationshipDiff), :relationships)
      end
    end
  end
end
