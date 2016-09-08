# frozen_string_literal: true
module Archimate
  module Diff
    class ModelDiff
      attr_reader :model1, :model2

      def initialize(model1, model2)
        @model1 = model1
        @model2 = model2
      end

      def diffs
        diffs = []
        diffs << Difference.context(:id, :model).apply(StringDiff.new(model1.id, model2.id).diffs)
        diffs << Difference.context(:name, :model).apply(StringDiff.new(model1.name, model2.name).diffs)
        diffs << Difference.context(:documentation, :model).apply(
          UnorderedListDiff.new(model1.documentation, model2.documentation).diffs
        )
        diffs << Difference.context(:elements, :model).apply(
          UnorderedListDiff.new(model1.elements.values, model2.elements.values).diffs
        )
        diffs.flatten
      end
    end
  end
end
