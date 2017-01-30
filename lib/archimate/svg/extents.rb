# frozen_string_literal: true
module Archimate
  module Svg
    Extents = Struct.new(:min_x, :max_x, :min_y, :max_y) do
      def expand(byval)
        self.min_x ||= 0
        self.max_x ||= 0
        self.min_y ||= 0
        self.max_y ||= 0
        self.min_x -= byval
        self.max_x += byval
        self.min_y -= byval
        self.max_y += byval
        self
      end

      def width
        max_x - min_x
      end

      def height
        max_y - min_y
      end
    end
  end
end
