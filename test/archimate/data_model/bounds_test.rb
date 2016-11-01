# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class BoundsTest < Minitest::Test
      def setup
        @b1 = Bounds.new(parent_id: nil, x: 0, y: 10, width: 500, height: 700)
        @b2 = Bounds.new(parent_id: nil, x: 0, y: 10, width: 500, height: 700)
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
        assert_kind_of Bounds, Bounds.new(parent_id: nil, x: nil, y: nil, width: 500, height: 700)
      end

      def test_width_required
        assert_raises { Bounds.new(parent_id: nil, x: 0, y: 10, width: nil, height: 700) }
      end

      def test_height_required
        assert_raises { Bounds.new(parent_id: nil, x: 0, y: 10, width: 500, height: nil) }
      end
    end
  end
end
