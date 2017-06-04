# frozen_string_literal: true

module Archimate
  module Svg
    class CssStyle
      attr_reader :style

      def initialize(style)
        @style = style
      end

      def text
        return "" if style.nil?
        to_css(
          "fill": style.font_color&.to_rgba,
          "color": style.font_color&.to_rgba,
          "font-family": style.font&.name,
          "font-size": style.font&.size,
          "text-align": style.text_align
        )
      end

      def to_css(style_hash)
        style_hash
          .delete_if { |_key, value| value.nil? }
          .map { |key, value| "#{key}:#{value};" }
          .join("")
      end
    end
  end
end
