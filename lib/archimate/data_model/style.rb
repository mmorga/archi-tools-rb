# frozen_string_literal: true
module Archimate
  module DataModel
    class Style < Dry::Struct::Value
      attribute :text_alignment, Coercible::Int.optional
      attribute :fill_color, OptionalColor
      attribute :line_color, OptionalColor
      attribute :font_color, OptionalColor
      attribute :line_width, Coercible::Int.optional
      attribute :font, OptionalFont
    end

    Dry::Types.register_class(Style)
    OptionalStyle = Style.optional
  end
end
