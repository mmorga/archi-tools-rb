# frozen_string_literal: true
module Archimate
  module DataModel
    class Style < Dry::Struct
      include DataModel::With

      attribute :text_alignment, Coercible::Int.optional
      attribute :fill_color, OptionalColor
      attribute :line_color, OptionalColor
      attribute :font_color, OptionalColor
      attribute :line_width, Coercible::Int.optional
      attribute :font, OptionalFont
      attribute :text_position, Coercible::Int.optional

      def clone
        Style.new(
          text_alignment: text_alignment,
          fill_color: fill_color&.clone,
          line_color: line_color&.clone,
          font_color: font_color&.clone,
          line_width: line_width,
          font: font&.clone,
          text_position: text_position
        )
      end

      def to_s
        attr_name_vals = struct_instance_variable_hash.map { |a, v| "#{a}: #{v}" }.join(", ")
        "Style(#{attr_name_vals})"
      end
    end

    Dry::Types.register_class(Style)
    OptionalStyle = Style.optional
  end
end
