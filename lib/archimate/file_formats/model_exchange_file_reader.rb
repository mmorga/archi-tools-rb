# frozen_string_literal: true
require "nokogiri"

module Archimate
  module FileFormats
    # This class implements common methods for the ArchiMate Model Exchange Format
    class ModelExchangeFileReader
      # Parses a Nokogiri document into an Archimate::Model
      def parse(doc)
        return unless doc
        parse_model(doc.root)
      end

      def parse_model(root)
        DataModel::Model.new(
          index_hash: {},
          id: identifier_to_id(root["identifier"]),
          name: ModelExchangeFile::XmlLangString.parse(root.at_css(">name")),
          version: root["version"],
          metadata: ModelExchangeFile::XmlMetadata.parse(root.at_css(">metadata")),
          documentation: parse_documentation(root),
          properties: parse_properties(root),
          elements: parse_elements(root),
          relationships: parse_relationships(root),
          organizations: parse_organizations(root.css(organizations_root_selector)),
          diagrams: parse_diagrams(root),
          viewpoints: [],
          property_definitions: parse_property_defs(root),
          schema_locations: root.attr("xsi:schemaLocation").split(" "),
          namespaces: root.namespaces,
          archimate_version: parse_archimate_version(root)
        )
      end


      def parse_documentation(node, element_name = "documentation")
        node.css(">#{element_name}").map do |doc|
          DataModel::Documentation.new(text: doc.content, lang: doc["xml:lang"])
        end
      end

      def parse_properties(node)
        node.css("> properties > property").map do |i|
          parse_property(i)
        end
      end

      def parse_property(node)
        DataModel::Property.new(
          property_definition_id: node.attr(property_def_attr_name),
          values: [ModelExchangeFile::XmlLangString.parse(node.at_css("value"))].compact
        )
      end

      def parse_property_defs(node)
        node.css(property_defs_selector).map do |i|
          DataModel::PropertyDefinition.new(
            id: i["identifier"],
            name: property_def_name(i),
            documentation: parse_documentation(i),
            value_type: i["type"]
          )
        end
      end

      def parse_elements(model)
        model.css(">elements>element").map do |i|
          DataModel::Element.new(
            id: identifier_to_id(i["identifier"]),
            name: parse_element_name(i),
            type: i["xsi:type"],
            documentation: parse_documentation(i),
            properties: parse_properties(i)
          )
        end
      end

      def parse_organizations(nodes)
        nodes.map do |i|
          child_items = i.css(">item")
          ref_items = child_items.select { |ci| ci.has_attribute?(identifier_ref_name) }
          DataModel::Organization.new(
            id: i["identifier"], # TODO: model exchange doesn't assign ids to organization items
            name: ModelExchangeFile::XmlLangString.parse(i.at_css(">label")),
            documentation: parse_documentation(i),
            items: ref_items.map { |ri| identifier_to_id(ri[identifier_ref_name]) },
            organizations: parse_organizations(child_items.reject { |ci| ci.has_attribute?(identifier_ref_name) })
          )
        end
      end

      def parse_relationships(model)
        model.css(">relationships>relationship").map do |i|
          DataModel::Relationship.new(
            id: identifier_to_id(i["identifier"]),
            type: i.attr("xsi:type"),
            source: identifier_to_id(i.attr("source")),
            target: identifier_to_id(i.attr("target")),
            name: parse_element_name(i),
            access_type: i["accessType"],
            documentation: parse_documentation(i),
            properties: parse_properties(i)
          )
        end
      end

      def parse_diagrams(model)
        model.css(diagrams_path).map do |i|
          nodes = parse_nodes(i)
          connections = parse_connections(i)
          child_id_hash = nodes.each_with_object({}) { |i2, a| a.merge!(i2.child_id_hash) }
          connections.each do |c|
            child_id_hash[c.source].connections << c
          end
          DataModel::Diagram.new(
            id: identifier_to_id(i["identifier"]),
            name: parse_element_name(i),
            viewpoint: i["viewpoint"],
            documentation: parse_documentation(i),
            properties: parse_properties(i),
            nodes: nodes,
            connections: connections,
            connection_router_type: i["connectionRouterType"],
            type: i.attr("xsi:type"),
            background: i.attr("background")
          )
        end
      end

      def parse_nodes(node)
        node.css("> node").map do |i|
          DataModel::ViewNode.new(
            id: identifier_to_id(i["identifier"]),
            type: i.attr(view_node_type_attr),
            model: nil,
            name: ModelExchangeFile::XmlLangString.parse(i.at_css(">label")),
            target_connections: [], # TODO: needed? "targetConnections",
            archimate_element: identifier_to_id(i[view_node_element_ref]),
            bounds: parse_bounds(i),
            nodes: parse_nodes(i),
            connections: parse_connections(i),
            documentation: parse_documentation(i),
            properties: parse_properties(i),
            style: parse_style(i),
            content: i.at_css("> content")&.text,
            child_type: nil
          )
        end
      end

      def parse_style(node)
        style = node.at_css(">style")
        return nil unless style
        DataModel::Style.new(
          text_alignment: style["textAlignment"],
          fill_color: parse_color(style, "fillColor"),
          line_color: parse_color(style, "lineColor"),
          font_color: parse_color(style.at_css(">font"), "color"),
          font: parse_font(style),
          line_width: style["lineWidth"],
          text_position: style.at_css("textPosition")
        )
      end

      def parse_font(node)
        font_node = node.at_css(">font")
        return unless font_node && font_node["name"] && font_node["size"]
        DataModel::Font.new(
          name: font_node["name"],
          size: font_node["size"],
          style: style_to_int(font_node["style"]),
          font_data: nil
        )
      end

      def parse_color(node, el_name)
        return unless node
        color_node = node.at_css(el_name)
        return unless color_node
        DataModel::Color.new(
          r: color_node["r"]&.to_i,
          g: color_node["g"]&.to_i,
          b: color_node["b"]&.to_i,
          a: color_node["a"]&.to_i
        )
      end

      def parse_bounds(node)
        DataModel::Bounds.new(
          x: node.attr("x"),
          y: node.attr("y"),
          width: node.attr("w"),
          height: node.attr("h")
        )
      end

      def parse_connections(node)
        node.css("> connection").map do |i|
          DataModel::Connection.new(
            id: identifier_to_id(i["identifier"]),
            type: i.attr(view_node_type_attr),
            source: identifier_to_id(i["source"]),
            target: identifier_to_id(i["target"]),
            relationship: identifier_to_id(i[connection_relationship_ref]),
            name: i.at_css("label")&.content,
            style: parse_style(i),
            bendpoints: parse_bendpoints(i),
            documentation: parse_documentation(i),
            properties: parse_properties(i)
          )
        end
      end

      def parse_bendpoints(node)
        node.css("bendpoint").map do |i|
          DataModel::Location.new(
            x: i.attr("x"), y: i.attr("y")
          )
        end
      end

      def identifier_to_id(str)
        # str&.sub(/^id-/, "")
        str
      end
    end
  end
end
