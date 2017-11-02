# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class BoundsTest < Minitest::Test
      def setup
        @b1 = build_bounds(x: 0, y: 10, width: 500, height: 700)
        @b2 = build_bounds(x: 0, y: 10, width: 500, height: 700)
      end

      def test_factory
        subject = build_bounds
        assert subject.x >= 0
        assert subject.y >= 0
        assert subject.width >= 0
        assert subject.height >= 0
      end

      def test_new
        assert_equal 0, @b1.x
        assert_equal 10, @b1.y
        assert_equal 500, @b1.width
        assert_equal 700, @b1.height
      end

      def test_hash
        assert_equal @b1.hash, @b2.hash
      end

      def test_hash_diff
        refute_equal @b1.hash, build_bounds.hash
      end

      def test_operator_eqleql_true
        assert @b1 == @b2
      end

      def test_operator_eqleql_false
        refute @b1 == build_bounds
      end

      def test_optional_x_y
        assert_kind_of Bounds, build_bounds(x: nil, y: nil, width: 500, height: 700)
      end

      def test_width_required
        assert_raises { Bounds.new(x: 0, y: 10, height: 700) }
      end

      def test_height_required
        assert_raises { Bounds.new(x: 0, y: 10, width: 500) }
      end

      def test_to_s
        assert_equal "Bounds(x: #{@b1.x}, y: #{@b1.y}, width: #{@b1.width}, height: #{@b1.height})", @b1.to_s
      end

      def test_zero
        assert_equal Bounds.new(x: 0, y: 0, width: 0, height: 0), Bounds.zero
      end
    end
  end
end
