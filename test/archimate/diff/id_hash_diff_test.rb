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

      def test_complex
        el1 = build(:element)
        el2 = build(:element)
        el3 = build(:element)
        el4 = build(:element)
        el2b = el2.dup
        el2b.label += "-changed"

        h1 = [el1, el2, el3].each_with_object({}) { |i, a| a[i.identifier] = i }
        h2 = [el1, el2b, el4].each_with_object({}) { |i, a| a[i.identifier] = i }
        diffs = Context.new(h1, h2).diffs(IdHashDiff.new(ElementDiff))
        expected = [
          Difference.change("Hash/label", el2.label, el2b.label),
          Difference.delete(el3.identifier, el3),
          Difference.insert(el4.identifier, el4)
        ]
        assert_equal(expected, diffs)
      end
    end
  end
end
