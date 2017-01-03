# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class ArchimateArrayReferenceTest < Minitest::Test
      using DataModel::DiffableArray

      def setup
        @model = build_model(with_relationships: 2, with_diagrams: 2, with_elements: 3, with_folders: 4)
        @subject = ArchimateArrayReference.new(@model.elements, 1)
        @other = @model.clone
      end

      def test_initialize
        assert_same @model.elements, @subject.archimate_node
        assert_equal 1, @subject.array_index
      end

      def test_lookup_in_model
        assert_same @other.elements[1], @subject.lookup_in_model(@other)
      end

      def test_lookup_parent_in_model
        assert_same @other.elements, @subject.lookup_parent_in_model(@other)
      end

      def test_parent
        assert_equal @model.elements, @subject.parent
      end

      def test_to_s
        assert_equal @model.elements[1].to_s, @subject.to_s
      end

      def test_value
        assert_same @model.elements[1], @subject.value
      end
    end
  end
end
