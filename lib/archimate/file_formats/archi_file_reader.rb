# frozen_string_literal: true
module Archimate
  module FileFormats
    class ArchiFileReader
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
        parse(Nokogiri::XML(archifile))
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
        node.css(">#{element_name}").each_with_object([]) do |i, a|
          a << DataModel::Documentation.new(text: i.content)
        end
      end

      def parse_properties(node)
        node.css(">property").each_with_object([]) do |i, a|
          a << DataModel::Property.new(key: i["key"], value: i["value"]) unless i["key"].nil?
        end
      end

      def parse_elements(model)
        model.css(ArchiFileFormat::FOLDER_XPATHS.join(",")).css('element[id]').map do |i|
          DataModel::Element.new(
            id: i["id"],
            label: i["name"],
            type: i["xsi:type"].sub("archimate:", ""),
            documentation: parse_documentation(i),
            properties: parse_properties(i)
          )
        end
      end

      def parse_folders(node)
        node.css("> folder").each_with_object([]) do |i, a|
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
        node.css(">element[id]").each_with_object([]) { |i, a| a << i.attr("id") }
      end

      def parse_relationships(model)
        model.css(ArchiFileFormat::RELATION_XPATHS.join(",")).css("element").map do |i|
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
          DataModel::Diagram.new(
            id: i["id"],
            name: i["name"],
            viewpoint: i["viewpoint"],
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
          child_hash = {
            id: "id",
            type: "xsi:type",
            model: "model",
            name: "name",
            target_connections: "targetConnections",
            archimate_element: "archimateElement"
          }.each_with_object({}) do |(hash_attr, node_attr), a2|
            a2[hash_attr] = child_node.attr(node_attr) # if child_node.attributes.include?(node_attr)
          end
          child_hash[:bounds] = parse_bounds(child_node)
          child_hash[:children] = parse_children(child_node)
          child_hash[:source_connections] = parse_source_connections(child_node)
          child_hash[:documentation] = parse_documentation(child_node)
          child_hash[:properties] = parse_properties(child_node)
          child_hash[:style] = parse_style(child_node)
          child_hash[:content] = child_node.at_css("> content")&.text
          child_hash[:child_type] = child_node.attr("type")
          a << DataModel::Child.new(child_hash)
        end
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
        bounds = node.at_css("> bounds")
        DataModel::Bounds.new(
          x: bounds.attr("x"),
          y: bounds.attr("y"),
          width: bounds.attr("width"),
          height: bounds.attr("height")
        ) unless bounds.nil?
      end

      def parse_source_connections(node)
        node.css("> sourceConnection").each_with_object([]) do |i, a|
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
          a << DataModel::Bendpoint.new(
            start_x: i.attr("startX"), start_y: i.attr("startY"),
            end_x: i.attr("endX"), end_y: i.attr("endY")
          )
        end
      end
    end
  end
end
