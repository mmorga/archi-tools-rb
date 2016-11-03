# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class StyleTest < Minitest::Test
      def setup
        @text_alignment = 1
        @fill_color = build_color
        @line_color = build_color
        @font_color = build_color
        @line_width = 2
        @font = build_font

        @s1 = Style.new(
          parent_id: build_id,
          text_alignment: @text_alignment,
          fill_color: @fill_color,
          line_color: @line_color,
          font_color: @font_color,
          line_width: @line_width,
          font: @font
        )
        @s2 = build_style
      end

      def test_new
        assert_equal @text_alignment, @s1.text_alignment
        assert_equal @fill_color, @s1.fill_color
        assert_equal @line_color, @s1.line_color
        assert_equal @font_color, @s1.font_color
        assert_equal @line_width, @s1.line_width
        assert_equal @font, @s1.font
      end

      def test_hash
        assert_equal @s1.hash, Style.new(@s1.to_h).hash
      end

      def test_hash_diff
        refute_equal @s1.hash, @s2.hash
      end

      def test_operator_eqleql_true
        assert_equal @s1, Style.new(@s1.to_h)
      end

      def test_operator_eqleql_false
        refute_equal @s1, @s2
      end

      def test_to_s
        assert_match(/Style/, @s1.to_s)
        [:text_alignment, :fill_color, :line_color, :font_color, :line_width].each do |attr|
          assert_match(@s1.send(attr).to_s, @s1.to_s, "Expect to_s to include #{attr} value")
        end
      end
    end
  end
end
