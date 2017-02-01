# frozen_string_literal: true
require "nokogiri"

module Archimate
  module FileFormats
    class ArchiFileReader
      def self.read(archifile, aio)
        new(aio).read(
          case archifile
          when IO
            archifile
          when String
            File.read(archifile)
          end
        )
      end

      def self.parse(archi_string, aio)
        reader = new(aio)
        reader.read(archi_string)
      end

      def initialize(aio)
        @aio = aio
        @progress = nil
      end

      def read(archifile)
        parse(Nokogiri::XML(archifile))
      end

      def parse(doc)
        @size = 0
        doc.traverse { |_n| @size += 1 }
        @progress = @aio.create_progressbar(total: @size, title: "Parsing")
        tick
        DataModel::Model.new(
          id: doc.root["id"],
          name: doc.root["name"],
          documentation: parse_documentation(doc.root, "purpose"),
          properties: parse_properties(doc.root),
          elements: parse_elements(doc.root),
          folders: parse_folders(doc.root),
          relationships: parse_relationships(doc.root),
          diagrams: parse_diagrams(doc.root)
        )
      ensure
        @progress&.finish
        @progress = nil
      end

      def parse_documentation(node, element_name = "documentation")
        node.css(">#{element_name}").each_with_object([]) do |i, a|
          tick
          a << DataModel::Documentation.new(text: i.content)
        end
      end

      def parse_properties(node)
        node.css(">property").each_with_object([]) do |i, a|
          tick
          a << DataModel::Property.new(key: i["key"], value: i["value"]) unless i["key"].nil?
        end
      end

      def parse_elements(model)
        model.css(ArchiFileFormat::FOLDER_XPATHS.join(",")).css('element[id]').map do |i|
          tick
          DataModel::Element.new(
            id: i["id"],
            label: i["name"],
            folder_id: i.parent["id"],
            type: i["xsi:type"].sub("archimate:", ""),
            documentation: parse_documentation(i),
            properties: parse_properties(i)
          )
        end
      end

      def parse_folders(node)
        node.css("> folder").each_with_object([]) do |i, a|
          tick
          a << DataModel::Folder.new(
            id: i.attr("id"),
            name: i.attr("name"),
            type: i.attr("type"),
            documentation: parse_documentation(i),
            properties: parse_properties(i),
            items: child_element_ids(i),
            folders: parse_folders(i)
          )
        end
      end

      def child_element_ids(node)
        node.css(">element[id]").each_with_object([]) do |i, a|
          tick
          a << i.attr("id")
        end
      end

      def parse_relationships(model)
        model.css(ArchiFileFormat::RELATION_XPATHS.join(",")).css("element").map do |i|
          tick
          DataModel::Relationship.new(
            id: i["id"],
            type: i.attr("xsi:type").sub("archimate:", ""),
            source: i.attr("source"),
            target: i.attr("target"),
            name: i["name"],
            access_type: i["accessType"],
            documentation: parse_documentation(i),
            properties: parse_properties(i)
          )
        end
      end

      def parse_diagrams(model)
        model.css(ArchiFileFormat::DIAGRAM_XPATHS.join(",")).css(
          'element[xsi|type="archimate:ArchimateDiagramModel"]',
          'element[xsi|type="archimate:SketchModel"]'
        ).map do |i|
          tick
          viewpoint_idx = i["viewpoint"]
          viewpoint_idx = viewpoint_idx.to_i unless viewpoint_idx.nil?
          viewpoint = viewpoint_idx.nil? ? nil : ArchiFileFormat::VIEWPOINTS[viewpoint_idx]
          DataModel::Diagram.new(
            id: i["id"],
            name: i["name"],
            viewpoint: viewpoint,
            documentation: parse_documentation(i),
            properties: parse_properties(i),
            children: parse_children(i),
            connection_router_type: i["connectionRouterType"],
            type: i.attr("xsi:type"),
            background: i.attr("background")
          )
        end
      end

      def parse_children(node)
        node.css("> child").each_with_object([]) do |child_node, a|
          tick
          a << DataModel::Child.new(
            id: child_node.attr("id"),
            type: child_node.attr("xsi:type"),
            model: child_node.attr("model"),
            name: child_node.attr("name"),
            target_connections: parse_target_connections(child_node.attr("targetConnections")),
            archimate_element: child_node.attr("archimateElement"),
            bounds: parse_bounds(child_node),
            children: parse_children(child_node),
            source_connections: parse_source_connections(child_node),
            documentation: parse_documentation(child_node),
            properties: parse_properties(child_node),
            style: parse_style(child_node),
            content: child_node.at_css("> content")&.text,
            child_type: child_node.attr("type")
          )
        end
      end

      def parse_target_connections(str)
        return [] if str.nil?
        str.split(" ")
      end

      def parse_style(style)
        tick
        DataModel::Style.new(
          text_alignment: style["textAlignment"],
          fill_color: DataModel::Color.rgba(style["fillColor"]),
          line_color: DataModel::Color.rgba(style["lineColor"]),
          font_color: DataModel::Color.rgba(style["fontColor"]),
          font: DataModel::Font.archi_font_string(style["font"]),
          line_width: style["lineWidth"],
          text_position: style["textPosition"]
        )
      end

      def parse_bounds(node)
        bounds = node.at_css("> bounds")
        tick
        unless bounds.nil?
          DataModel::Bounds.new(
            x: bounds.attr("x"),
            y: bounds.attr("y"),
            width: bounds.attr("width"),
            height: bounds.attr("height")
          )
        end
      end

      def parse_source_connections(node)
        node.css("> sourceConnection").each_with_object([]) do |i, a|
          tick
          a << DataModel::SourceConnection.new(
            id: i["id"],
            type: i.attr("xsi:type"),
            source: i["source"],
            target: i["target"],
            relationship: i["relationship"],
            name: i["name"],
            style: parse_style(i),
            bendpoints: parse_bendpoints(i),
            documentation: parse_documentation(i),
            properties: parse_properties(i)
          )
        end
      end

      def parse_bendpoints(node)
        node.css("bendpoint").each_with_object([]) do |i, a|
          tick
          a << DataModel::Bendpoint.new(
            start_x: i.attr("startX"), start_y: i.attr("startY"),
            end_x: i.attr("endX"), end_y: i.attr("endY")
          )
        end
      end

      def tick
        @progress&.increment
      end
    end
  end
end
