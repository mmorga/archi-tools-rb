# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class UnorderedListDiffTest < Minitest::Test
      def setup
        @ul_diff = UnorderedListDiff.new
      end

      def test_empty
        ctx = Context.new([], [])
        assert_empty @ul_diff.diffs(ctx)
      end

      def test_addition
        ctx = Context.new([], ["hello"])
        assert_equal [Difference.insert(0, "hello")], @ul_diff.diffs(ctx)
      end

      def test_deletion
        ctx = Context.new(["hello"], [])
        diffs = @ul_diff.diffs(ctx)
        assert_equal 1, diffs.size
        assert_equal Difference.delete(0, "hello"), diffs.first
      end

      def test_complex
        ctx = Context.new(%w(hello and goodbye), %w(goodbye for now))
        diffs = @ul_diff.diffs(ctx)
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
