# frozen_string_literal: true

module Archimate
  module Svg
    Point = Struct.new(:x, :y) do
      def -(pt)
        Math.sqrt(
          ((pt.x - x) ** 2) +
          ((pt.y - y) ** 2)
        )
      end
    end
  end
end
