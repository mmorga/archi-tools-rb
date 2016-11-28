# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class ColorTest < Minitest::Test
      def setup
        @c1 = build_color(r: 0, g: 10, b: 255, a: 100)
        @c2 = build_color(r: 255, g: 100, b: 125, a: 50)
      end

      def test_new
        assert_equal 0, @c1.r
        assert_equal 10, @c1.g
        assert_equal 255, @c1.b
        assert_equal 100, @c1.a
      end

      def test_hash
        assert_equal @c1.hash, Color.new(@c1.to_h).hash
      end

      def test_hash_diff
        refute_equal @c1.hash, build_color.hash
      end

      def test_operator_eqleql_true
        assert_equal @c1, Color.new(@c1.to_h)
      end

      def test_operator_eqleql_false
        refute_equal @c1, @c2
      end

      def test_constraints
        assert_raises { Color.new(r: 0, g: nil, b: nil, a: nil) }
        assert_raises { Color.new(r: nil, g: nil, b: nil, a: nil) }
        assert_raises { Color.new(r: -1, g: 0, b: 0, a: 50) }
        assert_raises { Color.new(r: 256, g: 0, b: 0, a: 50) }
        assert_raises { Color.new(r: 0, g: 0, b: 0, a: 101) }
        assert_raises { Color.new(r: 0, g: 0, b: 0, a: -1) }
      end

      def test_to_rgba
        assert_equal "#ff647d80", @c2.to_rgba
      end

      def test_rgba
        subject = Color.rgba("#ff647d80")

        assert_equal @c2, subject
      end

      def test_black
        subject = Color.black
        assert_equal 0, subject.r
        assert_equal 0, subject.g
        assert_equal 0, subject.b
        assert_equal 100, subject.a
      end
    end
  end
end
