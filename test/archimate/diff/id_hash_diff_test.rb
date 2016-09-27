# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class IdHashDiffTest < Minitest::Test
      def setup
        @id_hash_diff = IdHashDiff.new(StringDiff)
      end

      def test_empty
        assert_empty @id_hash_diff.diffs(Context.new({}, {}))
      end

      def test_same
        h1 = { "123" => "hello" }
        h2 = h1.dup
        ctx = Context.new(h1, h2)
        assert_empty @id_hash_diff.diffs(ctx)
      end

      def test_addition
        h1 = {}
        h2 = { "123" => "hello" }

        ctx = Context.new(h1, h2)
        diffs = @id_hash_diff.diffs(ctx)
        assert_equal [Difference.insert("123", "hello")], diffs
      end

      def test_deletion
        h1 = { "123" => "hello" }
        h2 = {}
        ctx = Context.new(h1, h2)
        diffs = @id_hash_diff.diffs(ctx)
        assert_equal [Difference.delete("123", "hello")], diffs
      end
    end
  end
end
