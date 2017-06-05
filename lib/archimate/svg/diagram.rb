# frozen_string_literal: true

require "erb"
require "nokogiri"

module Archimate
  module Svg
    class Diagram
      attr_reader :diagram

      def initialize(diagram)
        @diagram = diagram
        @svg_template = Nokogiri::XML(SvgTemplate.new.to_s).freeze
      end

      def to_svg
        svg_doc = @svg_template.clone
        render_connections(
          render_elements(svg_doc.at_css("#archimate-diagram"))
        )
        update_viewbox(svg_doc.at_css("svg"))
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
          .map { |node| %w[x y width height].map { |attr| node.attr(attr).to_i } }
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
          .reduce(svg_node) { |svg, child| Child.new(child).render_elements(svg) }
      end

      def render_connections(svg_node)
        diagram
          .children
          .reduce(svg_node) { |svg, child| Child.new(child).render_connections(svg) }
      end
    end
  end
end
