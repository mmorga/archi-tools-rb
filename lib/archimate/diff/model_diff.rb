# frozen_string_literal: true
module Archimate
  module Diff
    class ModelDiff
      attr_reader :model1, :model2

      def initialize(model1, model2)
        @model1 = model1
        @model2 = model2
      end

      def context
        @context ||= Context.new(@model1, @model2)
      end

      def diffs
        context.diffs do |c|
          c.in(StringDiff.new, :id)
          c.in(StringDiff.new, :name)
          c.in(UnorderedListDiff.new, :documentation)
          c.in(UnorderedListDiff.new, :properties)
          c.in(IdHashDiff.new(ElementDiff), :elements)
          c.in(IdHashDiff.new(RelationshipDiff), :relationships)
        end
      end

      def original_diffs
        diffs = []
        diffs << Difference.context(:id, :model).apply(StringDiff.new(model1.id, model2.id).diffs)
        diffs << Difference.context(:name, :model).apply(StringDiff.new(model1.name, model2.name).diffs)
        diffs << Difference.context(:documentation, :model).apply(
          UnorderedListDiff.new(model1.documentation, model2.documentation).diffs
        )
        diffs << Difference.context(:properties, :model).apply(
          UnorderedListDiff.new(model1.properties, model2.properties).diffs
        )
        diffs << Difference.context(:elements, :model).apply(
          IdHashDiff.new(ElementDiff, model1.elements, model2.elements).diffs
        )
        diffs << Difference.context(:relationships, :model).apply(
          IdHashDiff.new(RelationshipDiff, model1.relationships, model2.relationships).diffs
        )
        diffs.flatten
      end
    end
  end
end
