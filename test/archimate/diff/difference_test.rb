# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class DifferenceTest < Minitest::Test
      def test_delete
        change = Difference.delete(0, "Something")
        assert_equal :delete, change.kind
        assert_equal "Something", change.from
        assert_equal 0, change.entity
      end

      def test_insert
        d = Difference.insert(:model, "to_val")
        assert_equal :model, d.entity
        assert_equal "to_val", d.to
      end

      def test_context
        d = Difference.context(:model)
        assert_equal :model, d.entity
      end

      def test_apply
        context = Difference.context(:model)
        diffs = [
          Difference.delete(0, "I'm deleted"),
          Difference.insert("I'm inserted", "bogus")
        ]
        context.apply(diffs).each do |d|
          assert_equal :model, d.entity
        end
      end
    end
  end
end
