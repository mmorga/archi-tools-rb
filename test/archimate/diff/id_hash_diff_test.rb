# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class IdHashDiffTest < Minitest::Test
      def setup
        @id_hash_diff = IdHashDiff.new(StringDiff)
      end

      def test_empty
        assert_empty @id_hash_diff.diffs({}, {})
      end

      def test_same
        h1 = { "123" => "hello" }
        h2 = h1.dup
        assert_empty @id_hash_diff.diffs(h1, h2)
      end

      def test_addition
        h1 = {}
        h2 = { "123" => "hello" }

        diffs = @id_hash_diff.diffs(h1, h2)
        assert_equal [Difference.insert("123", "hello")], diffs
      end

      def test_deletion
        h1 = { "123" => "hello" }
        h2 = {}
        diffs = @id_hash_diff.diffs(h1, h2)
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
        id_hash_diff = IdHashDiff.new(ElementDiff)
        diffs = id_hash_diff.diffs(h1, h2)
        expected = [
          Difference.change(:label, el2.label, el2b.label),
          Difference.delete(el3.identifier, el3),
          Difference.insert(el4.identifier, el4)
        ]
        assert_equal(expected, diffs)
      end
    end
  end
end
