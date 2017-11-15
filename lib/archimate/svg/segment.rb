# frozen_string_literal: true

module Archimate
  module Svg
    Segment = Struct.new(:a, :b) do
      def length
        b - a
      end

      def from_end(dist)
        length = b - a
        from_start(length - dist)
      end

      def from_start(dist)
        length = b - a
        return a if dist.negative?
        return b if length < dist
        point_at_percent(dist / length)
      end

      def point_at_percent(pct)
        Point.new(
          a.x + ((b.x - a.x) * pct),
          a.y + ((b.y - a.y) * pct)
        )
      end
    end
  end
end
