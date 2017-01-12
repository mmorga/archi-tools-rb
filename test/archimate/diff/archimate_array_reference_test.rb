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

      def test_move_with_primitive
        base = build_model(
          folders: [
            build_folder(
              items: %w(a b c)
            )
          ]
        )

        local = base.with(folders: [ base.folders[0].with(items: %w(a c b))])

        subject = ArchimateArrayReference.new(local.folders[0].items, 1)

        result = base.clone

        assert_same result.folders[0].items, subject.lookup_parent_in_model(result)
        refute_same local.folders[0].items, subject.lookup_parent_in_model(result)
        subject.move(result, ArchimateArrayReference.new(base.folders[0].items, 2))

        assert_equal local, result
      end

      def test_move_with_primitive_to_reverse_order
        base = build_model(
          folders: [
            build_folder(
              items: %w(a b c)
            )
          ]
        )

        local = base.with(folders: [ base.folders[0].with(items: %w(c b a))])
        result = base.clone

        ArchimateArrayReference.new(
          local.folders[0].items, 0
        ).move(result, ArchimateArrayReference.new(base.folders[0].items, 2))

        ArchimateArrayReference.new(
          local.folders[0].items, 1
        ).move(result, ArchimateArrayReference.new(base.folders[0].items, 1))

        ArchimateArrayReference.new(
          local.folders[0].items, 2
        ).move(result, ArchimateArrayReference.new(base.folders[0].items, 0))

        assert_equal local, result
      end

      def test_move_with_primitive2
        base = build_model(
          folders: [
            build_folder(
              items: %w(a c b)
            )
          ]
        )

        local = base.with(folders: [ base.folders[0].with(items: %w(a b c))])

        subject = ArchimateArrayReference.new(local.folders[0].items, 1)

        result = base.clone

        assert_same result.folders[0].items, subject.lookup_parent_in_model(result)
        refute_same local.folders[0].items, subject.lookup_parent_in_model(result)
        subject.move(result, ArchimateArrayReference.new(base.folders[0].items, 2))

        assert_equal local, result
      end
    end
  end
end
