# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class LocationTest < Minitest::Test
      def setup
        @b1 = build_location(x: 0, y: 10)
        @b2 = build_location(x: 0, y: 10)
      end

      def test_new
        assert_equal 0, @b1.x
        assert_equal 10, @b1.y
      end

      def test_hash
        assert_equal @b1.hash, @b2.hash
      end

      def test_hash_diff
        refute_equal @b1.hash, build_location.hash
      end

      def test_operator_eqleql_true
        assert @b1 == @b2
      end

      def test_operator_eqleql_false
        refute @b1 == build_bounds
      end

      def test_to_s
        assert_equal "Location(x: #{@b1.x}, y: #{@b1.y})", @b1.to_s
      end
    end
  end
end
