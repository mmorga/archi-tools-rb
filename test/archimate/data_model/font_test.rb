# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class FontTest < Minitest::Test
      def setup
        @name = Faker::Name.name
        @size = 16
        @style = "normal"

        @s1 = Font.new(
          name: @name,
          size: @size,
          style: @style
        )
        @s2 = build_font
      end

      def test_new
        assert_equal @name, @s1.name
        assert_equal @size, @s1.size
        assert_equal @style, @s1.style
      end

      def test_hash
        assert_equal @s1.hash, Font.new(@s1.to_h).hash
      end

      def test_hash_diff
        refute_equal @s1.hash, @s2.hash
      end

      def test_operator_eqleql_true
        assert_equal @s1, Font.new(@s1.to_h)
      end

      def test_operator_eqleql_false
        refute_equal @s1, @s2
      end
    end
  end
end
