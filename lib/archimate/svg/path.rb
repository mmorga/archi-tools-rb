# frozen_string_literal: true

module Archimate
  module Svg
    class Path
      attr_reader :connection

      def initialize(connection)
        @connection = connection
      end

      # @return Float length of this path
      def length
        segment_lengths.reduce(0) { |total, length| total + length }
      end

      # @return Point mid-point on Path
      def midpoint
        point(0.5)
      end

      # @param fraction Float 0.0-1.0
      # @return Point at the given percent along line between start and end
      def point(fraction)
        length_from_start = length * fraction
        segments.each do |a, b|
          seg_length = b - a
          if seg_length >= length_from_start
            pct = length_from_start / seg_length
            return Point.new(
              a.x + ((b.x - a.x) * pct),
              a.y + ((b.y - a.y) * pct)
            )
          else
            length_from_start -= seg_length
          end
        end
        Point.new(0.0, 0.0)
      end

      # builds the line coordinates for the path
      # rough drawing is the point at center of first element, point of each bendpoint, and center of end element
      # First naive implementation
      # if left/right range of both overlap, use centerpoint of overlap range as x val
      # if top/bottom range of both overlap, use centerpoint of overlap range as y val
      def d
        [move_to(points.first)].concat(points[1..-1].map { |pt| line_to(pt) }).join(" ")
      end

      def points
        @points ||= calc_points
      end

      def segments
        (0..points.length - 2).map { |i| [points[i], points[i + 1]] }
      end

      # Returns the lengths of each segment of the line
      def segment_lengths
        segments.map { |a, b| b - a }
      end

      private

      def source_bounds
        @source_bounds ||= connection.source_bounds || DataModel::Bounds.zero
      end

      def target_bounds
        @target_bounds ||= connection.target_bounds || DataModel::Bounds.zero
      end

      def normalized_bend_points
        connection
          .bendpoints
          .reject { |bendpoint| [source_bounds, target_bounds].any? { |bounds| bendpoint.inside?(bounds) } }
          .map { |bendpoint| DataModel::Bounds.from_location(bendpoint) }
      end

      def calc_points
        bounds = [source_bounds, normalized_bend_points, target_bounds].flatten

        points = []
        a = bounds.shift
        until bounds.empty?
          b = bounds.shift
          points.concat(bounds_to_points(a, b))
          a = b
        end
        points.uniq
      end

      # Takes the bounds of two objects and returns the optimal points
      # between from the edge of `a` to the edge of `b`
      # @param a [Bounds]
      # @param b [Bounds]
      def bounds_to_points(a, b)
        ax_range = a.x_range
        bx_range = b.x_range

        overlap_x_center = ranges_overlap(ax_range, bx_range)

        if overlap_x_center
          ax = bx = overlap_x_center
        elsif b.right_of?(a)
          ax = a.right
          bx = b.left
        else
          ax = a.left
          bx = b.right
        end

        ay_range = a.y_range
        by_range = b.y_range

        overlap_y_center = ranges_overlap(ay_range, by_range)

        if overlap_y_center
          ay = by = overlap_y_center
        elsif b.above?(a)
          ay = a.top
          by = b.bottom
        else
          ay = a.bottom
          by = b.top
        end

        [Point.new(ax, ay), Point.new(bx, by)]
      end

      def move_to(point)
        "M #{point.x} #{point.y}"
      end

      def line_to(point)
        "L #{point.x} #{point.y}"
      end

      # Returns the midpoint of the overlap of two ranges or nil if there is no overlap
      # @param r1 [Range]
      # @param r2 [Range]
      def ranges_overlap(r1, r2)
        begin_max = [r1, r2].map(&:begin).max
        end_min = [r1, r2].map(&:end).min
        return nil if begin_max > end_min
        (begin_max + end_min) / 2.0
      end
    end
  end
end
