# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class AnyAttributeTest < Minitest::Test
      attr_reader :subject

      def setup
        @subject = AnyAttribute.new("attr", "val", prefix: "pr")
      end

      def test_comparison
        assert_equal [:attribute, :prefix, :value], AnyAttribute.attr_names
        assert_respond_to subject, :attribute
        assert_respond_to subject, :prefix
        assert_respond_to subject, :value
      end

      def test_factory
        subject = build_any_attribute
        refute_empty subject.attribute
        assert_empty subject.prefix
        refute_empty subject.value
      end

      def test_constructor_with_no_prefix
        subject = AnyAttribute.new("attr", "val")
        assert_equal "attr", subject.attribute
        assert_equal "val", subject.value
        assert_empty subject.prefix
      end

      def test_constructor_with_prefix
        assert_equal "attr", subject.attribute
        assert_equal "val", subject.value
        assert_equal "pr", subject.prefix
      end

      def test_enumerable
        expected = [:attribute, :prefix, :value]
        subject.each do |key_val|
          assert_equal expected.shift, key_val
        end
      end
    end
  end
end
