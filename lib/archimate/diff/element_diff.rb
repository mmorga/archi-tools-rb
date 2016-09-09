# frozen_string_literal: true
module Archimate
  module Diff
    class ElementDiff
      attr_reader :element1, :element2

      def initialize(element1, element2)
        @element1 = element1
        @element2 = element2
      end

      # :identifier, :type, :label, :documentation, :properties
      def diffs
        diffs = []
        diffs << Difference.context(:identifier, :element).apply(StringDiff.new(element1.identifier, element2.identifier).diffs)
        diffs << Difference.context(:type, :element).apply(StringDiff.new(element1.type, element2.type).diffs)
        diffs << Difference.context(:label, :element).apply(StringDiff.new(element1.label, element2.label).diffs)
        diffs << Difference.context(:documentation, :element).apply(
          UnorderedListDiff.new(element1.documentation, element2.documentation).diffs
        )
        diffs << Difference.context(:properties, :element).apply(
          UnorderedListDiff.new(element1.properties, element2.properties).diffs
        )
        diffs.flatten
      end
    end
  end
end
