# frozen_string_literal: true

require 'harfbuzz'

module Archimate
  module Svg
    class Text
      attr_reader :text
      attr_reader :face
      attr_reader :font
      attr_reader :style
      attr_reader :funits_per_em
      attr_reader :font_size_px
      attr_reader :line_height
      attr_reader :fonts_lib

      # TODO: Set up a means to establish defaults for font, etc.
      def initialize(text, style = nil)
        @text = text
        @style = style
        @fonts_lib = FontsLib.instance
        @face = Harfbuzz::Face.new(File.open(fonts_lib.path_to(style&.font&.name), 'rb'))
        @font = Harfbuzz::Font.new(face)
        @funits_per_em = face.upem.to_f
        @font_size_px = style&.font&.size || 11.0
        @line_height = 1.4 * font_size_px
      end

      # Converts a value in font units to px
      #
      # @see https://docs.microsoft.com/en-us/typography/opentype/spec/ttch01
      #
      # pointSize * resolution / ( 72 points per inch * units_per_em )
      #
      # where pointSize is the size at which the glyph is to be displayed, and resolution is the resolution of the output device. The 72 in the denominator reflects the number of points per inch.
      #
      # For example, assume that a glyph feature is 550 funits_per_em in length on a 72 dpi screen at 18 point. There are 2048 units per em. The following calculation reveals that the feature is 4.83 pixels long.
      #
      # 550 * 18 * 72 / ( 72 * 2048 ) = 4.83
      #
      # @see https://www.w3.org/TR/2008/REC-CSS2-20080411/syndata.html#length-units
      #
      # SVG 1.1 Spec recommends a reference pixel use a DPI of 90, but it would
      # seem that Archi's ArchiMate renderer defaults to 72 DPI.
      REFERENCE_DPI = 72.0
      def font_to_px(font_units)
        @funits_scale ||= font_size_px * REFERENCE_DPI / (72.0 * funits_per_em)
        font_units * @funits_scale
      end

      # TODO: Add a strategy to split by spaces & dashes & strip each line
      def layout_with_max(max_widths)
        split_by_word(text).each_with_object([[String.new, 0]]) do |str, lines|
          max_width = lines.length > max_widths.length ? max_widths.last : max_widths[lines.length - 1]
          if lines.last[0].empty?
            len = Text.new(str).layout.width
            if len > max_width
              lines.pop
              lines.concat(layout_with_max_by_char(str, max_width))
              next
            end
            line_str = str
          else
            line_str = lines.last[0] + " " + str
            len = Text.new(line_str).layout.width
            if len > max_width
              lines << [String.new, 0]
              len = Text.new(str).layout.width
              line_str = str
            end
          end
          lines.last[0] = line_str
          lines.last[1] = len
        end
      end

      def split_by_word(str)
        str.split(/\s/)
      end

      def layout_with_max_by_char(str, max_width)
        str.chars.each_with_object([[String.new, 0]]) do |char, lines|
          len = Text.new(lines.last[0] + char).layout.width
          if len > max_width
            lines << [String.new, 0]
            len = Text.new(char).layout.width
          end
          lines.last[0] << char
          lines.last[1] = len
        end
      end

      def layout
        buffer = Harfbuzz::Buffer.new
        buffer.add_utf8(text.to_s.encode('utf-8'))
        buffer.guess_segment_properties
        Harfbuzz.shape(font, buffer, %w[+ccmp +kern])
        buffer.normalize_glyphs
        buffer
          .get_glyph_positions
          .reduce(
            DataModel::Bounds.new(x: 0, y: 0, width: 0, height: line_height)
          ) do |bounds, gp|
          DataModel::Bounds.new(
            x: bounds.x,
            y: bounds.y,
            width: bounds.width + font_to_px(gp.x_offset + gp.x_advance),
            height: bounds.height
          )
        end
      end
    end
  end
end
