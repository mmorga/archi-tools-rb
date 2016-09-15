# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Model
    class RelationshipTest < Minitest::Test
      def test_new
        rel = build_relationship(id: "123", name: "my rel", documentation: %w(documentation1 documentation2))
        assert_equal "123", rel.id
        assert_equal "my rel", rel.name
        assert_equal %w(documentation1 documentation2), rel.documentation
      end

      def xtest_add_element
        rel = build_rel(with_elements: 3)
        el_count = rel.elements.size
        expected = build_element
        rel.add_element(expected)
        assert_equal el_count + 1, rel.elements.size
        assert_equal expected, rel.elements[expected.id]
      end

      def xtest_equality_operator
        m1 = build_rel(with_elements: 3)
        m2 = m1.dup
        assert_equal m1, m2
      end

      def xtest_equality_operator_false
        m1 = build_rel(with_elements: 3)
        m2 = m1.dup
        m2.name = "felix"
        refute_equal m1, m2
      end

      def xtest_apply_diff_insert
        fail "noprah!"
      end
    end
  end
end
