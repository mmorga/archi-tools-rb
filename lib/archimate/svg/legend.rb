# frozen_string_literal: true

require "nokogiri"

module Archimate
  module Svg
    class Legend
      attr_reader :svg_diagram
      attr_reader :legend_group
      attr_reader :columns
      attr_reader :element_width
      attr_reader :element_height
      attr_reader :line_height
      attr_reader :text_indent
      attr_reader :description_width
      attr_reader :col_width
      attr_reader :row_height
      attr_reader :top_margin
      attr_reader :section_width
      attr_reader :legend_width
      attr_reader :layers
      attr_reader :element_classes
      attr_reader :relationship_classes

      def initialize(svg_diagram)
        @svg_diagram = svg_diagram
        @legend_group = svg_diagram.legend_group
        @top_margin = 25
        @columns = 2
        @element_width = 110
        @element_height = 50
        @line_height = 15
        @text_indent = 10
        @description_width = 500
        @col_width = element_width + text_indent + description_width + text_indent
        @row_height = element_height + text_indent
        @section_width = columns * col_width
        @legend_width = text_indent * 2 + columns * col_width
        diagram = svg_diagram.diagram
        @element_classes = diagram.elements.map(&:class).uniq
        @layers = diagram.elements.map(&:layer).uniq.sort
        @relationship_classes = diagram.relationships.map(&:class).uniq
      end

      def remove
        legend_group.remove
      end

      def insert
        Nokogiri::XML::Builder.with(legend_group) do |xml|
          legend_for_relationship_classes(xml,
                                          legend_for_element_types_by_layer(xml,
                                                                            top_level_legend(xml)))
        end
      end

      def top_level_legend(xml)
        text(legend_left, legend_top, legend_width, legend_height, "Legend", "archimate-legend", xml) + line_height
      end

      def legend_for_element_types_by_layer(xml, top)
        layers.inject(top) do |section_top, layer|
          section_legend(section_top, layer.name, layer.background_class, layer_elements(layer), xml)
        end
      end

      def legend_for_relationship_classes(xml, top)
        return top if relationship_classes.empty?

        section_legend(top, "Relationships", "archimate-other-background", relationship_classes, xml)
      end

      def section_legend(top, heading, css_class, items, xml)
        sec_height = section_height(items)
        top = text(legend_left + text_indent, top, section_width, sec_height, heading, css_class, xml)
        items.each_with_index do |item, idx|
          item_example(item_x(idx), item_y(top, idx), item, xml)
        end
        top + sec_height
      end

      # Legend entry for a particular element type
      def item_example(x, y, klass, xml)
        klass_name = klass.name.split("::").last
        if klass.superclass == DataModel::Element
          element_example(x, y, klass, klass_name, xml)
        elsif klass.superclass == DataModel::Relationship
          relationship_example(x, y, klass_name, xml)
        end
        element_type_description(klass::DESCRIPTION, text_bounds(x, y), xml)
      end

      def element_example(x, y, klass, klass_name, xml)
        case klass_name
        when "Junction"
          r = (element_height - 10) / 4

          xml.circle(cx: x + r, cy: y + r, r: r, style: "fill:#000;stroke:#000")
          xml.text_(x: x + r * 2 + text_indent, y: y + r + line_height / 2, class: "archimate-legend-title") do
            xml.text("And Junction")
          end
          xml.circle(cx: x + r, cy: y + row_height / 2 + r, r: r, style: "fill:#fff;stroke:#000")
          xml.text_(x: x + r * 2 + text_indent, y: y + row_height / 2 + r + line_height / 2, class: "archimate-legend-title") do
            xml.text("Or Junction")
          end
        else
          element = DataModel::Elements.const_get(klass_name).new(id: "legend-element-#{klass_name}", name: klass::NAME)
          view_node = DataModel::ViewNode.new(
            id: "legend-element-type-#{klass_name}",
            name: klass::NAME,
            type: klass_name,
            element: element,
            diagram: svg_diagram.diagram,
            bounds: DataModel::Bounds.new(x: x, y: y, width: element_width, height: element_height)
          )
          EntityFactory.make_entity(view_node, nil).to_svg(xml)
        end
      end

      def relationship_example(x, y, klass_name, xml)
        css_class = "archimate-#{klass_name.downcase} archimate-relationship"
        xml.path(d: "M#{x} #{y + row_height / 2} h #{element_width}", class: css_class)
      end

      # Paragraph that describes a element or relationship
      def element_type_description(text, text_bounds, xml)
        css_style = "height:#{text_bounds.height}px;width:#{text_bounds.width}px;"
        xml.foreignObject(text_bounds.to_h) do
          xml.table(xmlns: "http://www.w3.org/1999/xhtml", style: css_style) do
            xml.tr(style: "height:#{text_bounds.height}px;") do
              xml.td(class: "entity-description") do
                xml.p(class: "entity-description") do
                  text.tr("\r\n", "\n").split(/[\r\n]/).each do |line|
                    xml.text(line)
                    xml.br
                  end
                end
              end
            end
          end
        end
      end

      def text(x, y, width, height, str, css_class, xml)
        css_style = "fill-opacity: 0.4"
        xml.rect(x: x, y: y - line_height, width: width, height: height,
                 rx: 5, ry: 5, class: css_class, style: css_style)
        xml.text_(x: x + text_indent, y: y, class: "archimate-legend-title") do
          xml.text(str)
        end
        y + line_height
      end

      def extents
        @extents ||= svg_diagram.calculate_max_extents
      end

      def diagram_width
        @diagram_width ||= extents.width
      end

      def legend_top
        extents.max_y + top_margin
      end

      def legend_left
        extents.min_x
      end

      def layer_elements(layer)
        element_classes.select { |k| k::LAYER == layer }
      end

      def legend_height
        height = layers.inject(line_height) do |h, layer|
          h + rows(layer_elements(layer)) * row_height + line_height * 3
        end + line_height
        height += rows(relationship_classes) * row_height + line_height * 3 unless relationship_classes.empty?
        height
      end

      def rows(items)
        (items.size / columns.to_f).round
      end

      def section_height(items)
        rows(items) * row_height + line_height * 2
      end

      def item_x(idx)
        legend_left + (text_indent * 2) + (col_width * (idx % columns))
      end

      def item_y(top, idx)
        top + (row_height * (idx / columns))
      end

      def text_bounds(x, y)
        DataModel::Bounds.new(
          x: x + element_width + text_indent,
          y: y,
          width: description_width,
          height: element_height
        )
      end
    end
  end
end
