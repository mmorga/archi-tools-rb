# frozen_string_literal: true
module Archimate
  module Svg
    class Connection
      attr_reader :source_connection

      def initialize(source_connection)
        @source_connection = source_connection
      end

      def to_svg(xml)
        return if source_connection.source_element.children.include?(source_connection.target_element)
        xml.path(path_attrs) do
          xml.title @source_connection.description
        end

        name = source_connection&.relationship_element&.name&.strip
        if !name.nil? && !name.empty?
          xml.text_(class: "archimate-relationship-name", dy: -2, "text-anchor" => "middle", style: text_style) do
            xml.textPath(startOffset: text_position, "xlink:href" => "##{source_connection.id}") do
              xml.text name
            end
          end
        end
      end

      def line_style
        style = source_connection.style
        return "" if style.nil?
        {
          "stroke": style.line_color&.to_rgba,
          "stroke-width": style.line_width
        }.delete_if { |key, value| value.nil? }
          .map { |key, value| "#{key}:#{value};"}
          .join("")
      end

      def text_position
        case source_connection.style
        when 0
          "10%"
        when 1
          "90%"
        else
          "50%"
        end
      end

      def text_style
        style = source_connection.style
        return "" if style.nil?
        {
          "fill": style.font_color&.to_rgba,
          "color": style.font_color&.to_rgba,
          "font-family": style.font&.name,
          "font-size": style.font&.size,
          "text-align": style.text_align
        }.delete_if { |key, value| value.nil? }
          .map { |key, value| "#{key}:#{value};"}
          .join("")
      end

      def path_attrs
        {
          id: source_connection.id,
          class: path_class,
          d: path_d,
          style: line_style
        }
      end

      # Look at the type (if any of the path and set the class appropriately)
      def path_class
        [
          "archimate",
          css_classify(source_connection&.relationship_element&.type || "default")
        ].join("-") + " archimate-relationship"
      end

      # TODO: StringRefinements refinement isn't working in this class, so added this method here. Investigate.
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

        start_point = DataModel::Bounds.new(
          x: source_bounds.left + source_bounds.width / 2.0,
          y: source_bounds.top + source_bounds.height / 2.0,
          width: 0,
          height: 0
        )
        bp_bounds = source_connection.bendpoints.map do |bp|
          DataModel::Bounds.new(
            x: start_point.x + (bp.start_x || 0),
            y: start_point.y + (bp.start_y || 0),
            width: 0,
            height: 0
          )
        end
        bp_bounds = bp_bounds.reject do |bounds|
          bounds.inside?(source_bounds) || bounds.inside?(target_bounds)
        end

        bounds = [source_bounds].concat(bp_bounds) << target_bounds

        points = []
        a = bounds.shift
        until (bounds.empty?)
          b = bounds.shift
          points.concat(calc_points(a, b))
          a = b
        end
        points.uniq!
        [move_to(points.shift)].concat(points.map{ |pt| line_to(pt) }).join(" ")
      end

      # a: Bounds
      # b: Bounds
      def calc_points(a, b)
        ax_range = a.x_range
        bx_range = b.x_range

        overlap_x_center = ranges_overlap(ax_range, bx_range)

        if overlap_x_center
          ax = bx = overlap_x_center
        elsif b.is_right_of?(a)
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
        elsif b.is_above?(a)
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
    end
  end
end
