# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Svg
    # What do I need to do here?
    # Need a layout and renderer sizing for text.
    # It needs to support being given a rect to render into
    # It needs to wrap text where necessary
    # It needs to support multi-line
    # It needs to truncate when the text is too long
    # It needs to support font face/size/style/decoration/
    # It needs to support defaults if fonts can't be found
    class TextTest < Minitest::Test
      attr_reader :subject

      def setup
        @subject = Text.new("Default Render")
      end

      # Firefox Browser renders:
      # Arial @ 11px size to 73.9833 x 12.5
      # Arial @ 16px size to 107.633 x 18
      # Lucida Grande @ 11px to 79.4333 x 13.5
      # Lucida Grande @ 16px to 115.6 x 19
      #
      # The default is Lucida Grande @ 11px
      def test_default_render
        bounds = subject.layout
        assert_equal 0, bounds.x
        assert_equal 0, bounds.y
        assert_in_delta 79.4333, bounds.width, 1.0
        assert_in_delta 11 * 1.4, bounds.height, 1.0
      end

      def test_default_font_size
        assert_equal 11.0, subject.font_size_px
      end

      def test_default_line_height
        assert_equal 11 * 1.4, subject.line_height
      end
    end
  end
end
