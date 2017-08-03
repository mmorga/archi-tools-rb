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
        set_title(svg_doc)
        top_group = svg_doc.at_css("#archimate-diagram")
        render_connections(
          render_elements(top_group)
        )
        update_viewbox(svg_doc.at_css("svg"))
        format_node(top_group)
        svg_doc.to_xml(encoding: 'UTF-8', indent: 2)
      end

      def set_title(svg)
        svg.at_css("title").content = diagram.name || "untitled"
        svg.at_css("desc").content = diagram.documentation.to_s || ""
      end

      # Scan the SVG and figure out min & max
      def update_viewbox(svg)
        extents = calculate_max_extents(svg).expand(10)
        svg.set_attribute(:width, extents.width)
        svg.set_attribute(:height, extents.height)
        svg.set_attribute("viewBox", "#{extents.min_x} #{extents.min_y} #{extents.width} #{extents.height}")
        svg
      end

      def format_node(node, depth = 4)
        node.children.each do |child|
          child.add_previous_sibling("\n#{ ' ' * depth }")
          format_node(child, depth + 2)
          child.add_next_sibling("\n#{ ' ' * (depth - 2) }") if node.children.last == child
        end
      end

      def calculate_max_extents(doc)
        node_vals =
          doc
          .xpath("//*[@x or @y]")
          .map { |node| %w[x y width height].map { |attr| node.attr(attr).to_i } }
        doc.css(".archimate-relationship")
          .each { |path|
            path.attr("d").split(" ").each_slice(3) do |point|
              node_vals << [point[1].to_i, point[2].to_i, 0, 0]
            end
          }
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
          .nodes
          .reduce(svg_node) { |svg, child| Child.new(child).render_elements(svg) }
      end

      def render_connections(svg_node)
        diagram
          .connections
          .reduce(svg_node) { |svg, connection| Connection.new(connection).render(svg) }
      end
    end
  end
end
