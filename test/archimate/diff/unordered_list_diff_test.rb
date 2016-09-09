# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class UnorderedListDiffTest < Minitest::Test
      def setup
        @ul_diff = UnorderedListDiff.new
      end

      def test_empty
        assert_empty @ul_diff.diffs([], [])
      end

      def test_addition
        assert_equal [Difference.insert(0, "hello")], @ul_diff.diffs([], ["hello"])
      end

      def test_deletion
        diffs = @ul_diff.diffs(["hello"], [])
        assert_equal 1, diffs.size
        assert_equal Difference.delete(0, "hello"), diffs.first
      end

      def test_complex
        diffs = @ul_diff.diffs(%w(hello and goodbye), %w(goodbye for now))
        assert_equal 4, diffs.size
        assert_equal(
          [
            Difference.delete(0, "hello"),
            Difference.delete(1, "and"),
            Difference.insert(1, "for"),
            Difference.insert(2, "now")
          ], diffs
        )
      end
    end
  end
end
