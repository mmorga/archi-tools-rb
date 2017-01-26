# frozen_string_literal: true
module Archimate
  module DataModel
    class Bounds < ArchimateNode
      attribute :x, Coercible::Float.optional
      attribute :y, Coercible::Float.optional
      attribute :width, Coercible::Float
      attribute :height, Coercible::Float

      def self.zero
        Archimate::DataModel::Bounds.new(x: 0, y: 0, width: 0, height: 0)
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
    end

    Dry::Types.register_class(Bounds)
  end
end
