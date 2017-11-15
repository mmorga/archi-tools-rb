# frozen_string_literal: true

module Archimate
  module Svg
    Point = Struct.new(:x, :y) do
      def -(other)
        Math.sqrt(
          ((other.x - x)**2) +
          ((other.y - y)**2)
        )
      end

      def to_s
        [x, y].map(&:to_s).join(" ")
      end
    end
  end
end
