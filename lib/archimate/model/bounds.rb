module Archimate
  module Model
    class Bounds
      attr_reader :x, :y, :width, :height

      def initialize(x, y, width, height)
        @x = x
        @y = y
        @width = width
        @height = height
      end

      def ==(other)
        @x == other.x &&
          @y == other.y &&
          @width == other.width &&
          @height == other.height
      end

      def hash
        self.class.hash ^
          @x.hash ^
          @y.hash ^
          @width.hash ^
          @height.hash
      end
    end
  end
end
