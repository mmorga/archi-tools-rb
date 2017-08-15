# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class RelationshipTest < Minitest::Test
      def test_list_factory
        given_elements = [build_element]
        given_relationships = [build_relationship]
        rels = build_relationship_list(elements: given_elements, relationships: given_relationships, with_relationships: 3)
        assert_equal 4, rels.size
        assert given_relationships.all? { |rel| rels.include?(rel) }
        assert rels.all? { |rel| rel.is_a?(Relationship) }
      end

      def test_build_test_helper
        docs = PreservedLangString.new(lang_hash: {"en" => "Something", "es" => "Hola"}, default_lang: "en", default_text: "Something")
        rel = build_relationship(id: "123", name: "my rel", documentation: docs)
        assert_equal "123", rel.id
        assert_equal "my rel", rel.name.to_s
        assert_equal docs, rel.documentation
      end

      def test_new_with_defaults
        src = build_element
        target = build_element
        rel = Relationship.new(
          id: "abc123",
          type: "complicated",
          source: src,
          target: target
        )
        assert_equal "abc123", rel.id
        assert_equal "complicated", rel.type
        assert_equal src, rel.source
        assert_equal target, rel.target
      end

      def test_new_duplicate_passed
        r1 = build_relationship
        r2 = Relationship.new(r1.to_h)
        assert_equal r1, r2
        refute_same r1, r2
      end

      def test_new_duplicate_with_args
        r1 = build_relationship
        r2 = Relationship.new(r1.to_h.merge(name: LangString.string("pablo")))
        refute_equal r1, r2
        assert_equal "pablo", r2.name.to_s
      end

      def test_attributes
        rel = build_relationship
        [:id, :name, :type, :source, :target, :documentation, :properties].each do |sym|
          assert rel.respond_to?(sym)
        end
      end

      def test_equality_operator
        m1 = build_relationship
        m2 = Relationship.new(m1.to_h)
        assert_equal m1, m2
      end

      def test_equality_operator_false
        m1 = build_relationship
        m2 = Relationship.new(m1.to_h.merge(name: LangString.string("felix")))
        refute_equal m1, m2
      end

      def test_to_s
        src_el = build_element
        target_el = build_element
        subject = build_relationship(
          id: "abc123",
          type: "AssociationRelationship",
          name: "friends",
          source: src_el,
          target: target_el
        )
        assert_equal(
          Archimate::Color.uncolor("AssociationRelationship<abc123>[friends] #{src_el} -> #{target_el}"),
          Archimate::Color.uncolor(subject.to_s)
        )
      end
    end
  end
end
