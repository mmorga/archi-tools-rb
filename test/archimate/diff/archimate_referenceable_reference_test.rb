# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class ArchimateReferenceableReferenceTest < Minitest::Test
      def setup
        skip("Diff re-write")
        @model = build_model(with_relationships: 2, with_diagrams: 2, with_elements: 3, with_organizations: 4)
        @subject = ArchimateReferenceableReference.new(@model.elements.first)

        @other = @model.with(elements: [build_element] + @model.elements)
      end

      def test_initialize
        skip("Diff re-write")
        assert_same @model.elements.first, @subject.archimate_node
      end

      def test_lookup_in_model_for_element
        skip("Diff re-write")
        assert_equal @other.elements[1], @subject.lookup_in_model(@other)
      end

      def test_lookup_parent_in_model
        skip("Diff re-write")
        assert_same @other.elements, @subject.lookup_parent_in_model(@other)
      end

      def test_parent
        skip("Diff re-write")
        assert_equal @model.elements, @subject.parent
      end

      def test_to_s
        skip("Diff re-write")
        assert_equal @model.elements[0].to_s, @subject.to_s
      end

      def test_value
        skip("Diff re-write")
        assert_same @model.elements[0], @subject.value
      end
    end
  end
end
