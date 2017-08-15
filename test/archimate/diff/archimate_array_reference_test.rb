# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class ArchimateArrayReferenceTest < Minitest::Test
      def setup
        skip("Diff re-write")
        @model = build_model(with_relationships: 2, with_diagrams: 2, with_elements: 3, with_organizations: 4)
        @subject = ArchimateArrayReference.new(@model.elements, 1)
        @other = @model.clone
      end

      def test_initialize
        skip("Diff rewrite")
        assert_same @model.elements, @subject.archimate_node
        assert_equal 1, @subject.array_index
      end

      def test_lookup_in_model
        skip("Diff rewrite")
        assert_same @other.elements[1], @subject.lookup_in_model(@other)
      end

      def test_lookup_parent_in_model
        skip("Diff rewrite")
        assert_same @other.elements, @subject.lookup_parent_in_model(@other)
      end

      def test_parent
        skip("Diff rewrite")
        assert_equal @model.elements, @subject.parent
      end

      def test_to_s
        skip("Diff rewrite")
        assert_equal @model.elements[1].to_s, @subject.to_s
      end

      def test_value
        skip("Diff rewrite")
        assert_same @model.elements[1], @subject.value
      end

      def test_move_with_primitive
        skip("Diff rewrite")
        base = build_model(
          organizations: [
            build_organization(
              items: %w(a b c)
            )
          ]
        )

        local = base.with(organizations: [ base.organizations[0].with(items: %w(a c b))])

        subject = ArchimateArrayReference.new(local.organizations[0].items, 1)

        result = base.clone

        assert_same result.organizations[0].items, subject.lookup_parent_in_model(result)
        refute_same local.organizations[0].items, subject.lookup_parent_in_model(result)
        subject.move(result, ArchimateArrayReference.new(base.organizations[0].items, 2))

        assert_equal local, result
      end

      def test_move_with_primitive_to_reverse_order
        skip("Diff rewrite")
        base = build_model(
          organizations: [
            build_organization(
              items: %w(a b c)
            )
          ]
        )

        local = base.with(organizations: [ base.organizations[0].with(items: %w(c b a))])
        result = base.clone

        ArchimateArrayReference.new(
          local.organizations[0].items, 0
        ).move(result, ArchimateArrayReference.new(base.organizations[0].items, 2))

        ArchimateArrayReference.new(
          local.organizations[0].items, 1
        ).move(result, ArchimateArrayReference.new(base.organizations[0].items, 1))

        ArchimateArrayReference.new(
          local.organizations[0].items, 2
        ).move(result, ArchimateArrayReference.new(base.organizations[0].items, 0))

        assert_equal local, result
      end

      def test_move_with_primitive2
        skip("Diff rewrite")
        base = build_model(
          organizations: [
            build_organization(
              items: %w(a c b)
            )
          ]
        )

        local = base.with(organizations: [ base.organizations[0].with(items: %w(a b c))])

        subject = ArchimateArrayReference.new(local.organizations[0].items, 1)

        result = base.clone

        assert_same result.organizations[0].items, subject.lookup_parent_in_model(result)
        refute_same local.organizations[0].items, subject.lookup_parent_in_model(result)
        subject.move(result, ArchimateArrayReference.new(base.organizations[0].items, 2))

        assert_equal local, result
      end
    end
  end
end
