# frozen_string_literal: true
module Archimate
  module DataModel
    class Style < Dry::Struct
      # specifies constructor style for Dry::Struct
      constructor_type :strict_with_defaults

      attribute :text_alignment, Coercible::Int.optional # TODO: make this an enum
      attribute :fill_color, Color.optional
      attribute :line_color, Color.optional
      attribute :font_color, Color.optional # TODO: move this to font
      attribute :line_width, Coercible::Int.optional
      attribute :font, Font.optional
      attribute :text_position, Coercible::Int.optional # TODO: make this an enum

      def to_s
        attr_name_vals = [:text_alignment, :fill_color, :line_color, :font_color, :line_width,
        :font, :text_position].map { |k| "#{k}: #{self[k]}" }.join(", ")
        "Style(#{attr_name_vals})"
      end

      def text_align
        case text_alignment
        when "1"
          "left"
        when "2"
          "center"
        when "3"
          "right"
        end
      end
    end

    Dry::Types.register_class(Style)
  end
end
