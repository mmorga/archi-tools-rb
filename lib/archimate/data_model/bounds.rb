# frozen_string_literal: true

module Archimate
  module DataModel
    class Bounds
      include Comparison

      # @!attribute [r] x
      #   @return [Float, NilClass]
      model_attr :x
      # @!attribute [r] y
      #   @return [Float, NilClass]
      model_attr :y
      # @!attribute [r] width
      #   @return [Float]
      model_attr :width
      # @!attribute [r] height
      #   @return [Float]
      model_attr :height

      def self.zero
        Archimate::DataModel::Bounds.new(x: 0, y: 0, width: 0, height: 0)
      end

      def initialize(x: nil, y: nil, width:, height:)
        raise "Width expected" unless width
        raise "Height expected" unless height
        @x = x.nil? ? nil : x.to_f
        @y = y.nil? ? nil : y.to_f
        @width = width.to_f
        @height = height.to_f
      end

      def to_s
        "Bounds(x: #{x}, y: #{y}, width: #{width}, height: #{height})"
      end

      def x_range
        Range.new(left, right)
      end

      def y_range
        Range.new(top, bottom)
      end

      def top
        y || 0
      end

      def bottom
        top + height
      end

      def right
        left + width
      end

      def left
        x || 0
      end

      def center
        DataModel::Bounds.new(
          x: left + width / 2.0,
          y: top + height / 2.0,
          width: 0,
          height: 0
        )
      end

      def is_above?(other)
        bottom < other.top
      end

      def is_below?(other)
        top > other.bottom
      end

      def is_right_of?(other)
        left > other.right
      end

      def is_left_of?(other)
        right < other.left
      end

      def reduced_by(val)
        Bounds.new(x: left + val, y: top + val, width: width - val * 2, height: height - val * 2)
      end

      def inside?(other)
        left > other.left &&
          right < other.right &&
          top > other.top &&
          bottom < other.bottom
      end
    end
  end
end
