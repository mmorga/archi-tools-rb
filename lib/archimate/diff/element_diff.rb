# frozen_string_literal: true
module Archimate
  module Diff
    class ElementDiff
      def diffs(element1, element2)
        @string_diff ||= StringDiff.new
        @ul_diff ||= UnorderedListDiff.new
        diffs = []
        diffs << Difference.context(:identifier).apply(@string_diff.diffs(element1.identifier, element2.identifier))
        diffs << Difference.context(:type).apply(@string_diff.diffs(element1.type, element2.type))
        diffs << Difference.context(:label).apply(@string_diff.diffs(element1.label, element2.label))
        diffs << Difference.context(:documentation).apply(
          @ul_diff.diffs(element1.documentation, element2.documentation)
        )
        diffs << Difference.context(:properties).apply(
          @ul_diff.diffs(element1.properties, element2.properties)
        )
        diffs.flatten
      end
    end
  end
end
