# frozen_string_literal: true
module Archimate
  module DataModel
    class Font < Dry::Struct
      include DataModel::With

      attribute :parent_id, Strict::String
      attribute :name, Strict::String
      attribute :size, Coercible::Float.constrained(gt: 0.0)
      attribute :style, Strict::String.optional
      attribute :font_data, Strict::String.optional

      def comparison_attributes
        [:@name, :@size, :@style, :@font_data]
      end

      def clone
        Font.new(
          parent_id: parent_id&.clone,
          name: name.clone,
          size: size,
          style: style&.clone,
          font_data: font_data&.clone
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
    end

    Dry::Types.register_class(Font)
    OptionalFont = Font.optional
  end
end
