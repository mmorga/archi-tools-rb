# frozen_string_literal: true

module Archimate
  module DataModel
    class Style
      include Comparison

      # @todo make this an enum
      # @return [Int, NilClass]
      model_attr :text_alignment
      # @return [Color, NilClass]
      model_attr :fill_color
      # @return [Color, NilClass]
      model_attr :line_color
      # @todo move this to font
      # @return [Color, NilClass]
      model_attr :font_color
      # @return [Int, NilClass]
      model_attr :line_width
      # @return [Font, NilClass]
      model_attr :font
      # @todo make this an enum
      # @return [Int, NilClass]
      model_attr :text_position

      def initialize(text_alignment: nil, fill_color: nil, line_color: nil,
                     font_color: nil, line_width: nil, font: nil, text_position: nil)
        @text_alignment = text_alignment
        @fill_color = fill_color
        @line_color = line_color
        @font_color = font_color
        @line_width = line_width
        @font = font
        @text_position = text_position
      end

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
