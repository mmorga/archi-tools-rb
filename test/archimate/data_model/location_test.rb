# frozen_string_literal: true

require 'test_helper'

module Archimate
  module DataModel
    class LocationTest < Minitest::Test
      def setup
        @b1 = Location.new(x: 0, y: 10)
        @b2 = Location.new(x: 0, y: 10)
      end

      def test_new
        assert_equal 0, @b1.x
        assert_equal 10, @b1.y
      end

      def test_hash
        assert_equal @b1.hash, @b2.hash
      end

      def test_hash_diff
        refute_equal @b1.hash, Location.new(x: 1, y: 10).hash
      end

      def test_operator_eqleql_true
        assert @b1 == @b2
      end

      def test_operator_eqleql_false
        refute @b1 == build_bounds
        refute @b1 == Location.new(x: 1, y: 10)
        refute @b1 == Location.new(x: 0, y: 11)
      end

      def test_to_s
        assert_equal "Location(x: #{@b1.x}, y: #{@b1.y})", @b1.to_s
      end

      def test_inside?
        bounds = Bounds.new(x: 0, y: 0, width: 20, height: 20)
        assert @b1.inside?(bounds)
        assert Location.new(x: 0, y: 0).inside?(bounds)
        assert Location.new(x: 20, y: 20).inside?(bounds)
        refute Location.new(x: 21, y: 21).inside?(bounds)
      end
    end
  end
end
