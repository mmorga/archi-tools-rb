# frozen_string_literal: true

module Archimate
  module DataModel
    class Style
      include Comparison

      # @todo make this an enum
      # @!attribute [r] text_alignment
      # @return [Int, NilClass]
      model_attr :text_alignment, default: nil
      # @!attribute [r] fill_color
      # @return [Color, NilClass]
      model_attr :fill_color, default: nil
      # @!attribute [r] line_color
      # @return [Color, NilClass]
      model_attr :line_color, default: nil
      # @todo move this to font
      # @!attribute [r] font_color
      # @return [Color, NilClass]
      model_attr :font_color, default: nil
      # @!attribute [r] line_width
      # @return [Int, NilClass]
      model_attr :line_width, default: nil
      # @!attribute [r] font
      # @return [Font, NilClass]
      model_attr :font, default: nil
      # @todo make this an enum
      # @!attribute [r] text_position
      # @return [Int, NilClass]
      model_attr :text_position, default: nil

      def to_s
        attr_name_vals = %i[text_alignment fill_color line_color font_color line_width
                            font text_position].map { |k| "#{k}: #{send(k)}" }.join(", ")
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
  end
end
