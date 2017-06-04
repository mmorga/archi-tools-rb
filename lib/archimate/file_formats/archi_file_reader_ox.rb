# frozen_string_literal: true
require "ox"

module Archimate
  module FileFormats
    class ArchiFileReaderOx
      def self.read(archifile)
        new.read(
          case archifile
          when IO
            archifile
          when String
            File.read(archifile)
          end
        )
      end

      def self.parse(archi_string)
        reader = new
        reader.read(archi_string)
      end

      def read(archifile)
        parse(Ox.parse(archifile))
      end

      def parse(doc)
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
      end

      def parse_documentation(node, element_name = "documentation")
        node.locate(element_name).each_with_object([]) do |i, a|
          a << DataModel::Documentation.new(text: i.text)
        end
      end

      def parse_properties(node)
        node.locate("property").each_with_object([]) do |i, a|
          a << DataModel::Property.new(key: i["key"], value: i["value"]) unless i["key"].nil?
        end
      end

      def parse_elements(model)
        # model.css(ArchiFileFormat::FOLDER_XPATHS.join(",")).css('element[id]').map do |i|
        model
          .locate("folder")
          .select { |folder| ArchiFileFormat::ELEMENT_FOLDER_TYPES.include?(folder["type"]) }
          .reduce([]) { |a, folder| a.concat(folder.locate("*/element")) }
          .map do |i|
          DataModel::Element.new(
            id: i["id"],
            name: i["name"],
            type: i["xsi:type"].sub("archimate:", ""),
            documentation: parse_documentation(i),
            properties: parse_properties(i)
          )
        end
      end

      def parse_folders(node)
        node.locate("folder").each_with_object([]) do |i, a|
          a << DataModel::Folder.new(
            id: i["id"],
            name: i["name"],
            type: i["type"],
            documentation: parse_documentation(i),
            properties: parse_properties(i),
            items: child_element_ids(i),
            folders: parse_folders(i)
          )
        end
      end

      def child_element_ids(node)
        node.locate("element").each_with_object([]) { |i, a| a << i["id"] }
      end

      def parse_relationships(model)
        # model.css(ArchiFileFormat::RELATION_XPATHS.join(",")).css("element").map do |i|
        model
          .locate("folder")
          .select { |folder| ArchiFileFormat::RELATION_FOLDER_TYPES.include?(folder["type"]) }
          .reduce([]) { |a, folder| a.concat(folder.locate("*/element")) }
          .map do |i|
          DataModel::Relationship.new(
            id: i["id"],
            type: i["xsi:type"].sub("archimate:", ""),
            source: i["source"],
            target: i["target"],
            name: i["name"],
            access_type: i["accessType"],
            documentation: parse_documentation(i),
            properties: parse_properties(i)
          )
        end
      end

      # TODO: would this be all elements
      # 'element[xsi|type="archimate:ArchimateDiagramModel"]',
      # 'element[xsi|type="archimate:SketchModel"]'
      def parse_diagrams(model)
        model
          .locate("folder")
          .select { |folder| ArchiFileFormat::DIAGRAM_FOLDER_TYPES.include?(folder["type"]) }
          .reduce([]) { |a, folder| a.concat(folder.locate("*/element")) }
          .map do |i|
          DataModel::Diagram.new(
            id: i["id"],
            name: i["name"],
            viewpoint: i["viewpoint"],
            documentation: parse_documentation(i),
            properties: parse_properties(i),
            children: parse_children(i),
            connection_router_type: i["connectionRouterType"],
            type: i["xsi:type"],
            background: i["background"]
          )
        end
      end

      def parse_children(node)
        node.locate("child").each_with_object([]) do |child_node, a|
          a << DataModel::Child.new(
            id: child_node["id"],
            type: child_node["xsi:type"],
            model: child_node["model"],
            name: child_node["name"],
            target_connections: parse_target_connections(child_node["targetConnections"]),
            archimate_element: child_node["archimateElement"],
            bounds: parse_bounds(child_node),
            children: parse_children(child_node),
            source_connections: parse_source_connections(child_node),
            documentation: parse_documentation(child_node),
            properties: parse_properties(child_node),
            style: parse_style(child_node),
            content: child_node.locate("content")[0]&.text,
            child_type: child_node["type"]
          )
        end
      end

      def parse_target_connections(str)
        return [] if str.nil?
        str.split(" ")
      end

      def parse_style(style)
        style = DataModel::Style.new(
          text_alignment: style["textAlignment"],
          fill_color: DataModel::Color.rgba(style["fillColor"]),
          line_color: DataModel::Color.rgba(style["lineColor"]),
          font_color: DataModel::Color.rgba(style["fontColor"]),
          font: DataModel::Font.archi_font_string(style["font"]),
          line_width: style["lineWidth"],
          text_position: style["textPosition"]
        )
        style
      end

      def parse_bounds(node)
        bounds = node.locate("bounds")
        return if bounds.empty?
        bounds = bounds[0]
        unless bounds.nil?
          DataModel::Bounds.new(
            x: bounds["x"],
            y: bounds["y"],
            width: bounds["width"],
            height: bounds["height"]
          )
        end
      end

      def parse_source_connections(node)
        node.locate("sourceConnection").each_with_object([]) do |i, a|
          a << DataModel::SourceConnection.new(
            id: i["id"],
            type: i["xsi:type"],
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
        node.locate("bendpoint").each_with_object([]) do |i, a|
          a << DataModel::Bendpoint.new(
            start_x: i["startX"], start_y: i["startY"],
            end_x: i["endX"], end_y: i["endY"]
          )
        end
      end
    end
  end
end
