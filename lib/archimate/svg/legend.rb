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
      attr_reader :layers
      attr_reader :element_classes

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
      end

      def remove
        legend_group.remove
      end

      def insert
        @element_classes = svg_diagram.diagram.elements.map(&:class).uniq
        @layers = svg_diagram.diagram.elements.map(&:layer).uniq.sort
        Nokogiri::XML::Builder.with(legend_group) do |xml|
          layers.inject(legend_title(legend_top, xml)) do |y, layer|
            layer_legend(y, layer, layer_elements(layer), xml)
          end
        end
      end

      def layer_elements(layer)
        element_classes.select { |k| k::LAYER == layer }
      end

      def text(x, y, width, height, str, css_class, xml)
        xml.rect(x: x, y: y - line_height, width: width, height: height, rx: 5, ry: 5, class: css_class, style: "fill-opacity: 0.4")
        xml.text_(x: x + text_indent, y: y, class: "archimate-legend-title") do
          xml.text(str)
        end
        y + line_height
      end

      def legend_title(top, xml)
        legend_width = text_indent * 2 + columns * col_width
        legend_height = layers.inject(line_height) do |h, layer|
          rows = (layer_elements(layer).size / columns.to_f).round
          h + rows * row_height + line_height * 3
        end
        text(legend_left, top, legend_width, legend_height + line_height, "Legend", "archimate-legend", xml) + line_height
      end

      def layer_title(top, layer, w, h, xml)
        text(legend_left + text_indent, top, w, h, layer.name, layer.background_class, xml)
      end

      def layer_legend(top, layer, layer_elements, xml)
        rows = (layer_elements.size / columns.to_f).round
        w = col_width * columns
        h = rows * row_height + line_height * 2
        top = layer_title(top, layer, w, h, xml)
        layer_elements.each_with_index do |el, i|
          x = legend_left + (text_indent * 2) + (col_width * (i % columns))
          y = top + (row_height * (i / columns))
          element_entry(x, y, el, xml)
        end
        top + h
      end

      # TODO: need to handle special cases for junctions
      def element_entry(x, y, el_class, xml)
        klass_name = el_class.name.split("::").last
        if klass_name != "Junction"
          view_node = DataModel::ViewNode.new(
            id: "legend-element-type-#{klass_name}",
            name: el_class::NAME,
            type: klass_name,
            element: DataModel::Elements.const_get(klass_name).new(id: "legend-element-#{klass_name}", name: el_class::NAME),
            diagram: svg_diagram.diagram,
            bounds: DataModel::Bounds.new(x: x, y: y, width: element_width, height: element_height)
          )
          EntityFactory.make_entity(view_node, nil).to_svg(xml)
        end
        text_bounds = DataModel::Bounds.new(
          x: x + element_width + text_indent,
          y: y,
          width: description_width,
          height: element_height,
        )
        element_type_description(el_class::DESCRIPTION, text_bounds, xml)
      end

      def element_type_description(text, text_bounds, xml)
        xml.foreignObject(text_bounds.to_h) do
          xml.table(xmlns: "http://www.w3.org/1999/xhtml", style: "height:#{text_bounds.height}px;width:#{text_bounds.width}px;") do
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
    end
  end
end
