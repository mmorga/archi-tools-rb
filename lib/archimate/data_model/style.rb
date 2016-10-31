# frozen_string_literal: true
module Archimate
  module DataModel
    class Style < Dry::Struct
      attribute :text_alignment, Coercible::Int.optional
      attribute :fill_color, OptionalColor
      attribute :line_color, OptionalColor
      attribute :font_color, OptionalColor
      attribute :line_width, Coercible::Int.optional
      attribute :font, OptionalFont

      def clone
        Style.new(
          text_alignment: text_alignment,
          fill_color: fill_color.nil? ? nil : fill_color.clone,
          line_color: line_color.nil? ? nil : line_color.clone,
          font_color: font_color.nil? ? nil : font_color.clone,
          line_width: line_width,
          font: font.nil? ? nil : font.clone
        )
      end

      def describe(_model)
        inspect
      end
    end

    Dry::Types.register_class(Style)
    OptionalStyle = Style.optional
  end
end
