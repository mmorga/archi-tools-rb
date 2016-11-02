# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class RelationshipTest < Minitest::Test
      def test_build_test_helper
        docs = build_documentation_list(count: 2)
        rel = build_relationship(id: "123", name: "my rel", documentation: docs)
        assert_equal "123", rel.id
        assert_equal "my rel", rel.name
        assert_equal docs, rel.documentation
      end

      def test_create
        rel = Relationship.create(
          parent_id: build_id,
          id: "abc123",
          type: "complicated",
          source: "src",
          target: "tar"
        )
        assert_equal "abc123", rel.id
        assert_equal "complicated", rel.type
        assert_equal "src", rel.source
        assert_equal "tar", rel.target
      end

      def test_new_duplicate_passed
        r1 = build_relationship
        r2 = r1.with
        assert_equal r1, r2
        refute_same r1, r2
      end

      def test_new_duplicate_with_args
        r1 = build_relationship
        r2 = r1.with(name: "pablo")
        refute_equal r1, r2
        assert_equal "pablo", r2.name
      end

      def test_attributes
        rel = build_relationship
        [:id, :name, :type, :source, :target, :documentation, :properties].each do |sym|
          assert rel.respond_to?(sym)
        end
      end

      def test_equality_operator
        m1 = build_relationship
        m2 = m1.dup
        assert_equal m1, m2
      end

      def test_equality_operator_false
        m1 = build_relationship
        m2 = m1.with(name: "felix")
        refute_equal m1, m2
      end

      def test_to_s
        rel = build_relationship(
          id: "abc123",
          name: nil,
          type: "complicated",
          source: "src",
          target: "tar"
        )
        assert_equal "complicated<abc123>[] src -> tar", rel.to_s.uncolorize
      end

      def test_element_reference
        rel = build_relationship(
          id: "abc123",
          type: "complicated",
          source: "src",
          target: "tar"
        )
        assert_equal %w(src tar), rel.element_reference
      end
    end
  end
end
