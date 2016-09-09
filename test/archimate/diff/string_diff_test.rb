# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class StringDiffTest < Minitest::Test
      def setup
        @string_diff = StringDiff.new
      end

      def test_equivalent
        assert_empty @string_diff.diffs("hello", "hello")
      end

      def test_insert
        assert_equal [Difference.insert(nil, "hello")], @string_diff.diffs(nil, "hello")
      end

      def test_delete
        assert_equal [Difference.delete(nil, "hello")], @string_diff.diffs("hello", nil)
      end

      def test_change
        assert_equal [Difference.change(nil, "base", "change")], @string_diff.diffs("base", "change")
      end
    end
  end
end
