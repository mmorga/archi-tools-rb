# frozen_string_literal: true

using Archimate::CoreRefinements

module Archimate
  module Svg
    class Path
      LINE_CURVE_RADIUS = 5

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
        segments.each do |segment|
          return segment.from_start(length_from_start) if segment.length >= length_from_start
          length_from_start -= segment.length
        end
        Point.new(0.0, 0.0)
      end

      # New implementation of SVG d method for a set of points
      # making smooth curves at each bendpoint
      #
      # Given three points: a, b, c
      # The result should be:
      # (a is already part of the path -> first point is a move_to command)
      # line_to(segment(a-b) - curve_radius (from end))
      # q_curve(b, segment(b-c) - curve_radius (from start))
      #
      # For cases with more bendpoints (with values d, e, ...)
      # repeat the above section with c as the new a value (so then [c, d, e], [d, e, f], etc.)
      def d
        [move_to(points.first)]
          .concat(
            points
              .each_cons(3)
              .flat_map { |a, b, c| curve_segment(a, b, c) }
          )
          .concat([line_to(points.last)])
          .join(" ")
      end

      def curve_segment(a, b, c)
        pt1 = Segment.new(a, b).from_end(LINE_CURVE_RADIUS)
        pt2 = Segment.new(b, c).from_start(LINE_CURVE_RADIUS)
        [
          line_to(pt1),
          q_curve(b, pt2)
        ]
      end

      def points
        @points ||= calc_points
      end

      def segments
        (0..points.length - 2).map { |i| Segment.new(points[i], points[i + 1]) }
      end

      # Returns the lengths of each segment of the line
      def segment_lengths
        segments.map(&:length)
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
      # if left/right range of both overlap, use centerpoint of overlap range as x val
      # if top/bottom range of both overlap, use centerpoint of overlap range as y val
      # @param a [Bounds]
      # @param b [Bounds]
      def bounds_to_points(a, b)
        ax_range = a.x_range
        bx_range = b.x_range

        overlap_x_center = ax_range.overlap_midpoint(bx_range)

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

        overlap_y_center = ay_range.overlap_midpoint(by_range)

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
        "M #{point}"
      end

      def line_to(point)
        "L #{point}"
      end

      def q_curve(cp, pt)
        "Q #{cp} #{pt}"
      end
    end
  end
end
