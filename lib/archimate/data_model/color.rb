# frozen_string_literal: true

module Archimate
  module DataModel
    # RGBColorType in the XSD
    # RGB Color type.
    # The r, g, b attributes range from 0 - 255.
    # The a (alpha) transparency attribute is optional. 0 = full transparency, 100 = opaque.
    class Color
      include Comparison

      # @!attribute [r] r
      #   @return [Int] red component, value 0-255
      model_attr :r
      # @!attribute [r] g
      #   @return [Int] green component, value 0-255
      model_attr :g
      # @!attribute [r] b
      #   @return [Int] blue component, value 0-255
      model_attr :b
      # @!attribute [r] a
      #   @return [Int, NilClass] optional alpha component, value 0-100
      model_attr :a

      # Parses a CSS style color string into a color object
      # @param str [String] CSS color string
      # @return [Color]
      def self.rgba(str)
        return nil if str.nil?
        md = str.match(/#([\da-f]{2})([\da-f]{2})([\da-f]{2})([\da-f]{2})?/)
        return nil unless md
        new(
          r: md[1].to_i(16),
          g: md[2].to_i(16),
          b: md[3].to_i(16),
          a: md[4].nil? ? 100 : (md[4].to_i(16) / 256.0 * 100.0).to_i
        )
      end

      # Results in a Color instance for the color black
      # @return [Color]
      def self.black
        new(r: 0, g: 0, b: 0, a: 100)
      end

      def initialize(r:, g:, b:, a: nil)
        raise "r, g, b cannot be nil" if [r, g, b].any?(&:nil?)
        raise "r, g, b must be between 0 and 255" if [r, g, b].any? { |v| v < 0 || v > 255 }
        raise "a must be between 0 and 100" if a && (a < 0 || a > 100)
        @r = r
        @g = g
        @b = b
        @a = a
      end

      def to_s
        "Color(r: #{r}, g: #{g}, b: #{b}, a: #{a})"
      end

      def to_rgba
        a == 100 ? format("#%02x%02x%02x", r, g, b) : format("#%02x%02x%02x%02x", r, g, b, scaled_alpha)
      end

      private

      def scaled_alpha(max = 255)
        return max unless a
        (max * (a / 100.0)).round
      end
    end
  end
end
