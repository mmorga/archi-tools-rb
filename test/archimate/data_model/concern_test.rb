# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class ConcernTest < Minitest::Test
      attr_reader :concern
      attr_reader :concern2

      def setup
        @concern = build_concern
        @concern2 = Concern.new(
          label: LangString.new("label"),
          documentation: PreservedLangString.new("docs"),
          stakeholders: [LangString.new("stakeholder")]
        )
      end

      def test_new
        assert_equal "label", concern2.label.to_s
        assert_equal "docs", concern2.documentation.to_s
        assert_equal ["stakeholder"], concern2.stakeholders.map(&:to_s)
      end

      def test_factory
        assert_kind_of LangString, concern.label
        assert_nil concern.documentation
        assert_empty concern.stakeholders
      end

      def test_hash
        assert_equal concern.hash, Concern.new(concern.to_h).hash
      end

      def test_hash_diff
        refute_equal concern.hash, concern2.hash
      end

      def test_operator_eqleql_true
        assert_equal concern, Concern.new(concern.to_h)
      end

      def test_operator_eqleql_false
        refute_equal concern, concern2
      end

      def test_constraints
        assert_raises { Concern.new(documentation: [], stakeholders: []) }
      end
    end
  end
end
