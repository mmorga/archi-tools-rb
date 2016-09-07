# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class StringDiffTest < Minitest::Test
      def test_equivalent
        string_diffs = StringDiff.new("hello", "hello")
        assert_empty string_diffs.diffs
      end

      def test_insert
        string_diffs = StringDiff.new(nil, "hello")
        assert_equal [Difference.insert("hello")], string_diffs.diffs
      end

      def test_delete
        string_diffs = StringDiff.new("hello", nil)
        assert_equal [Difference.delete("hello")], string_diffs.diffs
      end

      def test_change
        string_diffs = StringDiff.new("base", "change")
        assert_equal [Difference.new(:change, nil, nil, "base", "change")], string_diffs.diffs
      end
    end
  end
end
