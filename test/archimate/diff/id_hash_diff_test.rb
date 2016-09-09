# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class IdHashDiffTest < Minitest::Test
      def test_empty
        assert_empty IdHashDiff.new(StringDiff, {}, {}).diffs
      end

      def test_same
        h1 = { "123" => "hello" }
        h2 = h1.dup
        assert_empty IdHashDiff.new(StringDiff, h1, h2).diffs
      end

      def test_addition
        h1 = {}
        h2 = { "123" => "hello" }

        diffs = IdHashDiff.new(StringDiff, h1, h2).diffs
        assert_equal [Difference.insert("hello", "hello", nil, "123")], diffs
      end

      def test_deletion
        h1 = { "123" => "hello" }
        h2 = {}
        diffs = IdHashDiff.new(StringDiff, h1, h2).diffs
        assert_equal [Difference.delete("hello", "hello", nil, "123")], diffs
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
        diffs = IdHashDiff.new(ElementDiff, h1, h2).diffs
        expected = [
          Difference.change(el2.label, el2b.label, :label, :element),
          Difference.delete(el3, el3, nil, el3.identifier),
          Difference.insert(el4, el4, nil, el4.identifier)
        ]
        assert_equal(expected, diffs)
      end
    end
  end
end
