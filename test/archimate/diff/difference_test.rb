# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class DifferenceTest < Minitest::Test
      def test_new
        change = Difference.delete("Something")
        assert_equal :delete, change.kind
        assert_equal "Something", change.from
      end

      def test_context
        d = Difference.context(:model, "123")
        assert_equal :model, d.entity
        assert_equal "123", d.parent
      end

      def test_apply
        context = Difference.context(:model, "123")
        diffs = [
          Difference.delete("I'm deleted"),
          Difference.insert("I'm inserted")
        ]
        context.apply(diffs).each do |d|
          assert_equal :model, d.entity
          assert_equal "123", d.parent
        end
      end
    end
  end
end
