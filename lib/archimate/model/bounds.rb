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
    end
  end
end
