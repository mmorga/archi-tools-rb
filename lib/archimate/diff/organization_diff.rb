# frozen_string_literal: true
module Archimate
  module Diff
    class OrganizationDiff
      def diffs(context)
        context.diff(IdHashDiff.new(FolderDiff), :folders)
      end
    end
  end
end
