# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class DiffableArrayTest < Minitest::Test
      using DiffableArray
      using DiffablePrimitive

      def setup
        @model = build_model(with_elements: 3)
        @subject = %w(apple orange banana)
      end

      def test_diff_on_nil
        assert_equal(
          [Diff::Delete.new(@subject)],
          @subject.diff(nil)
        )
      end

      def test_diff_on_non_array_error_state
        assert_raises(TypeError) { @subject.diff(42) }
      end

      def test_diff_on_empty
        assert_empty [].diff([])
      end

      def test_diff_with_all_same
        assert_empty @subject.diff(@subject)
      end

      def test_diff_with_insert
        other = @subject + ["peach"]
        result = @subject.diff(other)

        assert_equal(
          [Diff::Insert.new(other, "3")],
          result
        )
        assert_equal(
          "peach",
          result[0].to_value
        )
      end

      def test_diff_with_delete
        other = @subject - ["orange"]
        result = @subject.diff(other)

        assert_equal(
          [Diff::Delete.new(@subject, "1")],
          result
        )
      end

      def test_diff_with_primitive_change
        other = @subject + ["peach"] - ["orange"]
        result = @subject.diff(other)

        assert_equal(
          [Diff::Delete.new(@subject, "1"),
           Diff::Insert.new(other, "2")],
          result
        )
      end

      def test_assign_model
        assert_nil @subject.in_model
        @subject.assign_model(@model)
        assert_equal @model, @subject.in_model
      end

      def test_assign_parent
        assert_nil @subject.parent
        @subject.assign_parent(@model)
        assert_equal @model, @subject.parent
      end

      def test_match
        assert @subject.match(@subject)
        refute @subject.match([])
        refute @subject.match(%w(chevy ford toyota))
      end

      def test_path
        assert_equal "elements", @model.elements.path
        assert_equal "elements/0", @model.elements.first.path
        assert_equal "elements/2", @model.elements.last.path
      end

      def test_attribute_name
        assert_equal "0", @model.elements.attribute_name(@model.elements[0])
        assert_equal "2", @model.elements.attribute_name(@model.elements[2])
      end

      def test_primitive
        refute @subject.primitive?
      end
    end
  end
end
