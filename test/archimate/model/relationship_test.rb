# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Model
    class RelationshipTest < Minitest::Test
      def test_build_test_helper
        rel = build_relationship(id: "123", name: "my rel", documentation: %w(documentation1 documentation2))
        assert_equal "123", rel.id
        assert_equal "my rel", rel.name
        assert_equal %w(documentation1 documentation2), rel.documentation
      end

      def test_standard_new
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
    end
  end
end
