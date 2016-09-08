# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class UnorderedListDiffTest < Minitest::Test
      def test_empty
        assert_empty UnorderedListDiff.new([], []).diffs
      end

      def test_addition
        diffs = UnorderedListDiff.new([], ["hello"]).diffs
        assert_equal 1, diffs.size
        assert_equal Difference.insert("hello", nil, nil, 0), diffs.first
      end

      def test_deletion
        diffs = UnorderedListDiff.new(["hello"], []).diffs
        assert_equal 1, diffs.size
        assert_equal Difference.delete("hello", nil, nil, 0), diffs.first
      end

      def test_complex
        diffs = UnorderedListDiff.new(%w(hello and goodbye), %w(goodbye for now)).diffs
        assert_equal 4, diffs.size
        assert_equal(
          [
            Difference.delete("hello", nil, nil, 0),
            Difference.delete("and", nil, nil, 1),
            Difference.insert("for", nil, nil, 1),
            Difference.insert("now", nil, nil, 2)
          ], diffs
        )
      end
    end
  end
end
