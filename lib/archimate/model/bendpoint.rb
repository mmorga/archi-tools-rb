module Archimate
  module Model
    class Bendpoint
      attr_reader :start_x, :start_y, :end_x, :end_y

      def initialize(start_x, start_y, end_x, end_y)
        @start_x = start_x
        @start_y = start_y
        @end_x = end_x
        @end_y = end_y
      end

      def ==(other)
        @start_x == other.start_x &&
          @start_y == other.start_y &&
          @end_x == other.end_x &&
          @end_y == other.end_y
      end

      def hash
        self.class.hash ^
          @start_x.hash ^
          @start_y.hash ^
          @end_x.hash ^
          @end_y.hash
      end
    end
  end
end
