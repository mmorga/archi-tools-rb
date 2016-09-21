# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Model
    class BendpointTest < Minitest::Test
      def setup
        @b1 = Bendpoint.new(start_x: 0, start_y: 10, end_x: 500, end_y: 700)
        @b2 = Bendpoint.new(start_x: 0, start_y: 10, end_x: 500, end_y: 700)
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
    end
  end
end
