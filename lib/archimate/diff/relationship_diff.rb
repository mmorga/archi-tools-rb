# frozen_string_literal: true
module Archimate
  module Diff
    class RelationshipDiff
      attr_reader :relationship1, :relationship2

      def initialize(relationship1, relationship2)
        @relationship1 = relationship1
        @relationship2 = relationship2
      end

      # :id, :name, :type, :parent_xpath, :documentation, :properties, :source, :target
      def diffs
        diffs = []
        diffs << Difference.context(:id, :relationship).apply(StringDiff.new(relationship1.id, relationship2.id).diffs)
        diffs << Difference.context(:type, :relationship).apply(StringDiff.new(relationship1.type, relationship2.type).diffs)
        diffs << Difference.context(:name, :relationship).apply(StringDiff.new(relationship1.name, relationship2.name).diffs)
        diffs << Difference.context(:source, :relationship).apply(StringDiff.new(relationship1.source, relationship2.source).diffs)
        diffs << Difference.context(:target, :relationship).apply(StringDiff.new(relationship1.target, relationship2.target).diffs)
        diffs << Difference.context(:documentation, :relationship).apply(
          UnorderedListDiff.new(relationship1.documentation, relationship2.documentation).diffs
        )
        diffs << Difference.context(:properties, :model).apply(
          UnorderedListDiff.new(model1.properties, model2.properties).diffs
        )
        diffs.flatten
      end
    end
  end
end
