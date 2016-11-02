# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class BendpointTest < Minitest::Test
      def setup
        @parent_id = build_id
        @b1 = build_bendpoint(parent_id: @parent_id, start_x: 0, start_y: 10, end_x: 500, end_y: 700)
        @b2 = build_bendpoint(parent_id: @parent_id, start_x: 0, start_y: 10, end_x: 500, end_y: 700)
      end

      def test_new
        assert_equal 0, @b1.start_x
        assert_equal 10, @b1.start_y
        assert_equal 500, @b1.end_x
        assert_equal 700, @b1.end_y
      end

      def test_hash
        assert_equal @b1.hash, @b2.hash
      end

      def test_hash_diff
        refute_equal @b1.hash, build_bendpoint.hash
      end

      def test_operator_eqleql_true
        assert @b1 == @b2
      end

      def test_operator_eqleql_false
        refute @b1 == build_bounds
      end

      def test_at_least_two_attributes_must_be_present
        skip
        assert_raises { build_bendpoint(start_x: 0, start_y: nil, end_x: nil, end_y: nil) }
        assert_raises { build_bendpoint(start_x: nil, start_y: nil, end_x: nil, end_y: nil) }
      end

      def test_comparison_attributes
        assert_equal [:@start_x, :@start_y, :@end_x, :@end_y], @b1.comparison_attributes
      end

      def test_to_s
        assert_equal "Bendpoint(start_x: #{@b1.start_x}, start_y: #{@b1.start_y}, end_x: #{@b1.end_x}, end_y: #{@b1.end_y})", @b1.to_s
      end
    end
  end
end
