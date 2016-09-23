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
        el1 = build_element
        el2 = build_element
        el3 = build_element
        el4 = build_element
        el2b = el2.with(label: el2.label + "-changed")

        h1 = Archimate.array_to_id_hash([el1, el2, el3])
        h2 = Archimate.array_to_id_hash([el1, el2b, el4])
        diffs = Context.new(h1, h2).diffs(IdHashDiff.new(ElementDiff))
        expected = [
          Difference.change("#{el2.id}/label", el2.label, el2b.label),
          Difference.delete(el3.id, el3),
          Difference.insert(el4.id, el4)
        ]
        assert_equal(expected, diffs)
      end
    end
  end
end
