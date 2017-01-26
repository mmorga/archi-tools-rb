# frozen_string_literal: true
require "erb"

module Archimate
  module Svg
    Extents = Struct.new(:min_x, :max_x, :min_y, :max_y) do
      def expand(byval)
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

    class Diagram
      attr_reader :diagram

      def initialize(diagram, aio)
        @diagram = diagram
        @aio = aio
        @svg_template = Nokogiri::XML::Document.parse(SvgTemplate.new.to_s).freeze
      end

      def to_svg
        svg_doc = @svg_template.clone
        update_viewbox(
          render_connections(
            render_elements(svg_doc.at_css("svg"))
          )
        )
        svg_doc.to_xml(encoding: 'UTF-8', indent: 2)
      end

      # Scan the SVG and figure out min & max
      def update_viewbox(svg)
        extents = calculate_max_extents(svg).expand(10)
        svg.set_attribute(:width, extents.width)
        svg.set_attribute(:height, extents.height)
        svg.set_attribute("viewBox", "#{extents.min_x} #{extents.min_y} #{extents.width} #{extents.height}")
        svg
      end

      def calculate_max_extents(doc)
        node_vals =
          doc
          .xpath("//*[@x or @y]")
          .map { |node| %w(x y width height).map { |attr| node.attr(attr).to_i } }
        Extents.new(
          node_vals.map(&:first).min,
          node_vals.map { |v| v[0] + v[2] }.max,
          node_vals.map { |v| v[1] }.min,
          node_vals.map { |v| v[1] + v[3] }.max
        )
      end

      def attr_to_i(node, attr)
        ival = node.attr(attr)
        ival.to_i unless ival.nil? || ival.strip.empty?
      end

      def render_elements(svg_node)
        diagram
          .children
          .reduce(svg_node) { |svg, child| Child.new(child, @aio).render_elements(svg) }
      end

      def render_connections(svg_node)
        diagram
          .children
          .reduce(svg_node) { |svg, child| Child.new(child, @aio).render_connections(svg) }
      end
    end
  end
end
