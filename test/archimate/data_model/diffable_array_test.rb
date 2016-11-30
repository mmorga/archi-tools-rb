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

      def test_diff_with_delete_primitive
        other = @subject - ["orange"]
        result = @subject.diff(other)

        assert_equal(
          [Diff::Delete.new(@subject, "1")],
          result
        )
      end

      def test_diff_with_delete_and_apply
        base = build_model(with_elements: 3)
        merged = base.clone
        deleted_element = base.elements[1]
        local = base.with(elements: base.elements - [deleted_element])
        assert_equal local.elements.size, base.elements.size - 1

        result = base.diff(local)

        assert_equal([Diff::Delete.new(base.elements, 1)], result)
        assert_equal deleted_element.parent, result[0].effective_element

        merged.apply_diff(result[0])
        assert_equal local, merged
      end

      def test_diff_with_insert_and_apply
        base = build_model(with_elements: 3)
        merged = base.clone
        inserted_element = build_element
        local = base.with(elements: base.elements + [inserted_element])
        assert_equal local.elements.size, base.elements.size + 1

        result = base.diff(local)

        assert_equal([Diff::Insert.new(local.elements, 3)], result)
        assert_equal inserted_element.parent, result[0].effective_element

        merged.apply_diff(result[0])
        assert_equal local, merged
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

      def test_delete
        element_to_delete = @model.elements[1]
        subject = @model.clone
        subject.elements.delete("1", subject.elements[1])

        assert_includes @model.elements, element_to_delete
        refute_includes subject.elements, element_to_delete
      end

      def test_insert
        subject = @model.clone
        element_to_insert = build_element

        subject.elements.insert("3", element_to_insert)

        refute_includes @model.elements, element_to_insert
        assert_includes subject.elements, element_to_insert
        assert_equal 3, subject.elements.index(element_to_insert)
      end

      def test_change
        subject = @model.clone
        element_to_change = @model.elements[1]
        changed_element = element_to_change.with(label: element_to_change.label + "-changed")

        subject.elements.change("1", element_to_change, changed_element)

        refute_includes @model.elements, changed_element
        assert_includes subject.elements, changed_element
        assert_equal 1, subject.elements.index(changed_element)
      end
    end
  end
end
