# frozen_string_literal: true
module Archimate
  module DataModel
    class Style < Dry::Struct
      include With
      include DiffableStruct

      constructor_type :schema

      attribute :text_alignment, Coercible::Int.optional
      attribute :fill_color, Color.optional
      attribute :line_color, Color.optional
      attribute :font_color, Color.optional
      attribute :line_width, Coercible::Int.optional
      attribute :font, Font.optional
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
        attr_name_vals = to_h.keys.map { |k| "#{k}: #{send(k)}" }.join(", ")
        "Style(#{attr_name_vals})"
      end
    end

    Dry::Types.register_class(Style)
  end
end
