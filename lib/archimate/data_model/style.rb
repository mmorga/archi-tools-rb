# frozen_string_literal: true
module Archimate
  module DataModel
    class Style < Dry::Struct
      include DataModel::With

      attribute :parent_id, Strict::String
      attribute :text_alignment, Coercible::Int.optional
      attribute :fill_color, OptionalColor
      attribute :line_color, OptionalColor
      attribute :font_color, OptionalColor
      attribute :line_width, Coercible::Int.optional
      attribute :font, OptionalFont

      def comparison_attributes
        [:@text_alignment, :@fill_color, :@line_color, :@font_color, :@line_width, :@font]
      end

      def clone
        Style.new(
          parent_id: parent_id&.clone,
          text_alignment: text_alignment,
          fill_color: fill_color&.clone,
          line_color: line_color&.clone,
          font_color: font_color&.clone,
          line_width: line_width,
          font: font&.clone
        )
      end

      def to_s
        attr_name_vals = comparison_attributes.map { |ca| "#{ca.to_s.delete('@')}: #{instance_variable_get(ca)}" }.join(", ")
        "Style(#{attr_name_vals})"
      end
    end

    Dry::Types.register_class(Style)
    OptionalStyle = Style.optional
  end
end
