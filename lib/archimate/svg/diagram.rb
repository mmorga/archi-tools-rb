# frozen_string_literal: true

require "erb"
require "nokogiri"

module Archimate
  module Svg
    class Diagram
      attr_reader :diagram
      attr_reader :svg_doc
      attr_reader :options

      DEFAULT_SVG_OPTIONS = {
        legend: false,
        format_xml: true
      }.freeze

      def initialize(diagram, options = {})
        @diagram = diagram
        @options = DEFAULT_SVG_OPTIONS.merge(options)
        @svg_template = Nokogiri::XML(SvgTemplate.new.to_s).freeze
      end

      def to_svg
        @svg_doc = @svg_template.clone
        set_title
        render_connections(
          render_elements(archimate_diagram_group)
        )
        legend = Legend.new(self)
        if include_legend?
          legend.insert
        else
          legend.remove
        end
        update_viewbox
        format_node(archimate_diagram_group) if format_xml?
        format_node(legend_group) if include_legend? && format_xml?
        svg_doc.to_xml(encoding: 'UTF-8', indent: indentation)
      end

      def svg_element
        @svg_element ||= svg_doc.at_css("svg")
      end

      def archimate_diagram_group
        @archimate_diagram_group ||= svg_doc.at_css("#archimate-diagram")
      end

      def legend_group
        @legend_group ||= svg_doc.at_css("#archimate-legend")
      end

      def include_legend?
        options[:legend]
      end

      def format_xml?
        options[:format_xml]
      end

      def indentation
        format_xml? ? 2 : 0
      end

      def set_title
        svg_doc.at_css("title").content = diagram.name || "untitled"
        svg_doc.at_css("desc").content = diagram.documentation.to_s || ""
      end

      # Scan the SVG and figure out min & max
      def update_viewbox
        extents = calculate_max_extents.expand(10)
        svg_element.set_attribute(:width, extents.width)
        svg_element.set_attribute(:height, extents.height)
        svg_element.set_attribute("viewBox", "#{extents.min_x} #{extents.min_y} #{extents.width} #{extents.height}")
        svg_element
      end

      def format_node(node, depth = 4)
        node.children.each do |child|
          child.add_previous_sibling("\n#{' ' * depth}")
          format_node(child, depth + 2)
          child.add_next_sibling("\n#{' ' * (depth - 2)}") if node.children.last == child
        end
      end

      def calculate_max_extents
        node_vals =
          svg_element
          .xpath("//*[@x or @y]")
          .map { |node| %w[x y width height].map { |attr| node.attr(attr).to_i } }
        svg_element.css(".archimate-relationship")
                   .each do |path|
          path.attr("d").split(" ").each_slice(3) do |point|
            node_vals << [point[1].to_i, point[2].to_i, 0, 0]
          end
        end
        Extents.new(
          node_vals.map(&:first).min,
          node_vals.map { |v| v[0] + v[2] }.max,
          node_vals.map { |v| v[1] }.min,
          node_vals.map { |v| v[1] + v[3] }.max
        )
      end

      def render_elements(svg_node)
        diagram
          .nodes
          .reduce(svg_node) { |svg, view_node| ViewNode.new(view_node).render_elements(svg) }
      end

      def render_connections(svg_node)
        diagram
          .connections
          .reduce(svg_node) { |svg, connection| Connection.new(connection).render(svg) }
      end
    end
  end
end
