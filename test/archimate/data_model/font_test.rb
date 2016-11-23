# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class FontTest < Minitest::Test
      def setup
        @name = Faker::Name.name
        @size = 16.0
        @style = 0

        @s1 = build_font(
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

      def test_clone
        subject = @s1.clone

        assert_equal @s1, subject
        refute_equal @s1.object_id, subject.object_id
      end

      def test_hash
        assert_equal @s1.hash, Font.new(@s1.to_h).hash
      end

      def test_hash_diff
        refute_equal @s1.hash, @s2.hash
      end

      def test_operator_eqleql_false
        refute_equal @s1, @s2
      end

      def test_comparison_attributes
        assert_equal [:@name, :@size, :@style, :@font_data], @s1.comparison_attributes
      end

      def test_to_s
        assert_equal "Font(name: #{@name}, size: #{@size}, style: #{@style})", @s1.to_s
      end

      def test_archi_font_string
        [
          ["1|Arial|14.0|0|WINDOWS|1|0|0|0|0|0|0|0|0|1|0|0|0|0|Arial", "Arial", 14.0, 0],
          ["1|Arial|8.0|0|WINDOWS|1|0|0|0|0|0|0|0|0|1|0|0|0|0|Arial", "Arial", 8.0, 0],
          ["1|Segoe UI Semibold|12.0|2|WINDOWS|1|-16|0|0|0|600|-1|0|0|0|3|2|1|34|Segoe UI Semibold", "Segoe UI Semibold", 12.0, 2],
          ["1|Times New Roman|12.0|3|WINDOWS|1|-16|0|0|0|700|-1|0|0|0|3|2|1|18|Times New Roman", "Times New Roman", 12.0, 3],
        ].each do |fd, name, size, style|
          assert_equal(
            Font.new(parent_id: "", name: name, size: size, style: style, font_data: fd),
            Font.archi_font_string(fd)
          )
        end
      end
    end
  end
end
