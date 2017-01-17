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

      def test_new_with_defaults
        rel = Relationship.new(
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
        src_el = build_element
        target_el = build_element
        subject = build_relationship(
          id: "abc123",
          type: "AssociationRelationship",
          name: "friends",
          source: src_el.id,
          target: target_el.id
        )
        model = build_model(
          elements: [src_el, target_el],
          relationships: [
            subject
          ]
        )
        assert_equal(
          HighLine.uncolor("AssociationRelationship<abc123>[friends] #{src_el} -> #{target_el}"),
          HighLine.uncolor(model.relationships[0].to_s)
        )
      end

      def test_referenced_identified_nodes
        subject = build_relationship(
          source: "a",
          target: "b"
        )

        assert_equal %w(a b), subject.referenced_identified_nodes.sort
      end
    end
  end
end
