# frozen_string_literal: true
module Archimate
  module DataModel
    class Font < ArchimateNode
      attribute :name, Strict::String.optional
      attribute :size, Coercible::Float.constrained(gt: 0.0).optional
      attribute :style, Coercible::Int.optional # TODO: make this an enum
      attribute :font_data, Strict::String.optional

      # Archi font strings look like this:
      #  "1|Arial            |14.0|0|WINDOWS|1|0  |0|0|0|0  |0 |0|0|1|0|0|0|0 |Arial"
      #  "1|Arial            |8.0 |0|WINDOWS|1|0  |0|0|0|0  |0 |0|0|1|0|0|0|0 |Arial"
      #  "1|Segoe UI Semibold|12.0|2|WINDOWS|1|-16|0|0|0|600|-1|0|0|0|3|2|1|34|Segoe UI Semibold"
      #  "1|Times New Roman  |12.0|3|WINDOWS|1|-16|0|0|0|700|-1|0|0|0|3|2|1|18|Times New Roman"
      def self.archi_font_string(str)
        return nil if str.nil?
        font_parts = str.split("|")
        DataModel::Font.new(
          name: font_parts[1],
          size: font_parts[2],
          style: font_parts[3],
          font_data: str
        )
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

      # TODO: this isn't standard
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

    Dry::Types.register_class(Font)
  end
end
