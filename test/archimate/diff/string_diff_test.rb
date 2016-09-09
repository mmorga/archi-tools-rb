# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class StringDiffTest < Minitest::Test
      def setup
        @string_diff = StringDiff.new
      end

      def test_equivalent
        ctx = Context.new("hello", "hello")
        assert_empty @string_diff.diffs(ctx)
      end

      def test_insert
        ctx = Context.new(nil, "hello")
        assert_equal [Difference.insert("", "hello")], @string_diff.diffs(ctx)
      end

      def test_delete
        ctx = Context.new("hello", nil)
        assert_equal [Difference.delete("", "hello")], @string_diff.diffs(ctx)
      end

      def test_change
        ctx = Context.new("base", "change", "test")
        assert_equal [Difference.change("test", "base", "change")], @string_diff.diffs(ctx)
      end
    end
  end
end
