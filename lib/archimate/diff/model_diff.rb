# frozen_string_literal: true
module Archimate
  module Diff
    class ModelDiff
      attr_reader :kind, :location, :subject
      attr_reader :model1, :model2

      def initialize(model1, model2)
        @model1 = model1
        @model2 = model2
      end

      def diffs
        diffs = []
        diffs << Difference.context(:name, :model).apply(StringDiff.new(model1.name, model2.name).diffs)
        diffs.flatten
      end
    end
  end
end
