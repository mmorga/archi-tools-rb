# frozen_string_literal: true
module Archimate
  module Svg
    class Connection
      using StringRefinements

      attr_reader :source_connection

      def initialize(source_connection)
        @source_connection = source_connection
      end

      def to_svg(xml)
        xml.path(path_attrs) unless source_connection.source_element.children.include?(source_connection.target_element)
      end

      def path_attrs
        {
          id: source_connection.id,
          class: path_class,
          d: path_d
        }
      end

      # Look at the type (if any of the path and set the class appropriately)
      def path_class
        [
          "archimate",
          css_classify(source_connection&.relationship_element&.type || "default")
        ].join("-")
      end

      # TODO: refinement isn't working here. Investigate.
      def css_classify(str)
        str.gsub(/::/, '/')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1-\2')
          .gsub(/([a-z\d])([A-Z])/, '\1-\2')
          .downcase
      end

      def ranges_overlap(r1, r2)
        begin_max = [r1, r2].map(&:begin).max
        end_min = [r1, r2].map(&:end).min
        return nil if begin_max > end_min
        (begin_max + end_min) / 2.0
      end

      # builds the line coordinates for the path
      # rough drawing is the point at center of first element, point of each bendpoint, and center of end element
      # First naive implementation
      # if left/right range of both overlap, use centerpoint of overlap range as x val
      # if top/bottom range of both overlap, use centerpoint of overlap range as y val
      def path_d
        source_bounds = source_connection.source_element&.absolute_position || DataModel::Bounds.zero
        target_bounds = source_connection.target_element&.absolute_position || DataModel::Bounds.zero

        source_x_range = source_bounds.x_range
        target_x_range = target_bounds.x_range

        overlap_x_center = ranges_overlap(source_x_range, target_x_range)

        if overlap_x_center
          start_x = overlap_x_center
          end_x = overlap_x_center
        elsif target_bounds.is_right_of?(source_bounds)
          start_x = source_bounds.right
          end_x = target_bounds.left
        else
          start_x = source_bounds.left
          end_x = target_bounds.right
        end

        source_y_range = source_bounds.y_range
        target_y_range = target_bounds.y_range

        overlap_y_center = ranges_overlap(source_y_range, target_y_range)

        if overlap_y_center
          start_y = overlap_y_center
          end_y = overlap_y_center
        elsif target_bounds.is_above?(source_bounds)
          start_y = source_bounds.top
          end_y = target_bounds.bottom
        else
          start_y = source_bounds.bottom
          end_y = target_bounds.top
        end

        [
          move_to(Point.new(start_x, start_y)),
          line_to(Point.new(end_x, end_y))
        ].join(" ")
      end

      def move_to(point)
        "M #{point.x} #{point.y}"
      end

      def line_to(point)
        "L #{point.x} #{point.y}"
      end
    end
  end
end
