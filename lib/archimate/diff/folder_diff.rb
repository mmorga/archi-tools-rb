# frozen_string_literal: true
module Archimate
  module Diff
    class FolderDiff
      def diffs(context)
        context.diff(StringDiff.new, :id)
        context.diff(StringDiff.new, :name)
        context.diff(StringDiff.new, :type)
        context.diff(UnorderedListDiff.new, :items)
        context.diff(IdHashDiff.new(FolderDiff), :folders)
        context.diff(UnorderedListDiff.new, :documentation)
        context.diff(UnorderedListDiff.new, :properties)
      end
    end
  end
end
