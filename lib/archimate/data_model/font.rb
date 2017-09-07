# frozen_string_literal: true

module Archimate
  module DataModel
    class Font
      include Comparison

      # @return [String, NilClass]
      model_attr :name
      # @return [Float, NilClass]
      model_attr :size
      # @todo make this an enum
      # @return [Int, NilClass]
      model_attr :style
      # @return [String, NilClass]
      model_attr :font_data

      # Archi font strings look like this:
      #  "1|Arial            |14.0|0|WINDOWS|1|0  |0|0|0|0  |0 |0|0|1|0|0|0|0 |Arial"
      #  "1|Arial            |8.0 |0|WINDOWS|1|0  |0|0|0|0  |0 |0|0|1|0|0|0|0 |Arial"
      #  "1|Segoe UI Semibold|12.0|2|WINDOWS|1|-16|0|0|0|600|-1|0|0|0|3|2|1|34|Segoe UI Semibold"
      #  "1|Times New Roman  |12.0|3|WINDOWS|1|-16|0|0|0|700|-1|0|0|0|3|2|1|18|Times New Roman"
      # @todo move this to the archi file reader
      def self.archi_font_string(str)
        return nil if str.nil?
        font_parts = str.split("|")
        DataModel::Font.new(
          name: font_parts[1],
          size: font_parts[2].to_f,
          style: font_parts[3].to_i,
          font_data: str
        )
      end

      def initialize(name: nil, size: nil, style: nil, font_data: nil)
        @name = name
        @size = size.nil? ? nil : size.to_f
        @style = style.nil? ? nil : style.to_i
        @font_data = font_data
      end

      def to_s
        "Font(name: #{name}, size: #{size}, style: #{style})"
      end

      def to_archi_font
        font_data ||
          [
            1, font.name, font.size, font.style, "WINDOWS", 1, 0, 0, 0, 0, 0, 0,
            0, 0, 1, 0, 0, 0, 0, font.name
          ].map(&:to_s).join("|")
      end

      # @todo this isn't standard
      # Move to file format
      def style_string
        case style
        when 1
          "italic"
        when 2
          "bold"
        when 3
          "bold|italic"
        end
      end
    end
  end
end
