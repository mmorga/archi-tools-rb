# frozen_string_literal: true
require "nokogiri"

module Archimate
  module FileFormats
    # This class implements common methods for the ArchiMate Model Exchange Format
    class ModelExchangeFileReader
      attr_reader :index

      # Parses a Nokogiri document into an Archimate::Model
      def parse(doc)
        return unless doc
        @property_defs = []
        @viewpoints = []
        @index = {}
        parse_model(doc.root)
      end

      def parse_model(root)
        @property_defs = parse_property_defs(root)
        @viewpoints = parse_viewpoints(root)
        properties = parse_properties(root)
        elements = parse_elements(root)
        relationships = parse_relationships(root)
        diagrams = parse_diagrams(root)
        organizations = parse_organizations(root.css(organizations_root_selector))
        model = DataModel::Model.new(
          id: identifier_to_id(root["identifier"]),
          name: ModelExchangeFile::XmlLangString.parse(root.at_css(">name")),
          version: root["version"],
          metadata: ModelExchangeFile::XmlMetadata.parse(root.at_css(">metadata")),
          documentation: parse_documentation(root),
          properties: properties,
          elements: elements,
          relationships: relationships,
          organizations: organizations,
          diagrams: diagrams,
          viewpoints: @viewpoints,
          property_definitions: @property_defs,
          schema_locations: root.attr("xsi:schemaLocation").split(" "),
          namespaces: root.namespaces,
          archimate_version: parse_archimate_version(root)
        )
        @index[model.id] = model
        model
      end

      def parse_viewpoints(_node)
        return []
      end

      # @deprecated
      # TODO: delete in favor of implementation in Reader
      def parse_documentation(node, element_name = "documentation")
        lang_hash = node
          .css(">#{element_name}")
          .reduce(Hash.new { |h, key| h[key] = [] }) do |h2, doc|
            h2[doc["xml:lang"]] << doc.content
            h2
          end
          .transform_values { |ary| ary.join("\n") }
        return nil if lang_hash.empty?
        default_lang = lang_hash.keys.first
        default_text = lang_hash[default_lang]
        DataModel::PreservedLangString.new(
          lang_hash: lang_hash,
          default_lang: default_lang,
          default_text: default_text
        )
      end

      def parse_properties(node)
        node.css("> properties > property").map do |i|
          parse_property(i)
        end
      end

      def parse_property(node)
        property_def = @property_defs.find { |prop_def| prop_def.id == node.attr(property_def_attr_name) }
        DataModel::Property.new(
          property_definition: property_def,
          value: ModelExchangeFile::XmlLangString.parse(node.at_css("value"))
        )
      end

      def parse_property_defs(node)
        @property_defs = node.css(property_defs_selector).map do |i|
          property_def = DataModel::PropertyDefinition.new(
            id: i["identifier"],
            name: property_def_name(i),
            documentation: parse_documentation(i),
            type: i["type"]
          )
          @index[property_def.id] = property_def
          property_def
        end
      end

      def parse_elements(model)
        model.css(">elements>element").map do |i|
          element = DataModel::Element.new(
            id: identifier_to_id(i["identifier"]),
            name: parse_element_name(i),
            type: i["xsi:type"],
            documentation: parse_documentation(i),
            properties: parse_properties(i)
          )
          @index[element.id] = element
          element
        end
      end

      def parse_organizations(nodes)
        nodes.map do |i|
          child_items = i.css(">item")
          ref_items = child_items.select { |ci| ci.has_attribute?(identifier_ref_name) }
          organization = DataModel::Organization.new(
            id: i["identifier"], # TODO: model exchange doesn't assign ids to organization items
            name: ModelExchangeFile::XmlLangString.parse(i.at_css(">label")),
            documentation: parse_documentation(i),
            items: ref_items.map { |ri| index[identifier_to_id(ri[identifier_ref_name])] },
            organizations: parse_organizations(child_items.reject { |ci| ci.has_attribute?(identifier_ref_name) })
          )
          @index[organization.id] = organization if organization.id
          organization
        end
      end

      def parse_relationships(model)
        model.css(">relationships>relationship").map do |i|
          relationship = DataModel::Relationship.new(
            id: identifier_to_id(i["identifier"]),
            type: i.attr("xsi:type"),
            source: index[i.attr("source")],
            target: index[i.attr("target")],
            name: parse_element_name(i),
            access_type: i["accessType"],
            documentation: parse_documentation(i),
            properties: parse_properties(i)
          )
          @index[relationship.id] = relationship
          relationship
        end
      end

      def parse_diagrams(model)
        model.css(diagrams_path).map do |i|
          diagram = DataModel::Diagram.new(
            id: identifier_to_id(i["identifier"]),
            name: parse_element_name(i),
            viewpoint_type: i["viewpoint"],
            viewpoint: nil, # TODO: support this for ArchiMate v3
            documentation: parse_documentation(i),
            properties: parse_properties(i),
            nodes: [],
            connections: [],
            connection_router_type: i["connectionRouterType"],
            type: i.attr("xsi:type"),
            background: i.attr("background")
          )
          @index[diagram.id] = diagram
          diagram.nodes = parse_view_nodes(i, diagram)
          diagram.connections = parse_connections(i)
          diagram
        end
      end

      def parse_view_nodes(node, diagram)
        node.css("> node").map do |i|
          view_node = DataModel::ViewNode.new(
            id: identifier_to_id(i["identifier"]),
            type: i.attr(view_node_type_attr),
            view_refs: nil,
            name: ModelExchangeFile::XmlLangString.parse(i.at_css(">label")),
            # target_connections: [], # TODO: needed? "targetConnections",
            element: index[identifier_to_id(i[view_node_element_ref])],
            bounds: parse_bounds(i),
            nodes: parse_view_nodes(i, diagram),
            connections: parse_connections(i),
            documentation: parse_documentation(i),
            properties: parse_properties(i),
            style: parse_style(i),
            content: i.at_css("> content")&.text,
            child_type: nil,
            diagram: diagram
          )
          @index[view_node.id] = view_node
          view_node
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
          connection = DataModel::Connection.new(
            id: identifier_to_id(i["identifier"]),
            type: i.attr(view_node_type_attr),
            source: index[i["source"]],
            target: index[i["target"]],
            relationship: index[i[connection_relationship_ref]],
            name: i.at_css("label")&.content,
            style: parse_style(i),
            bendpoints: parse_bendpoints(i),
            documentation: parse_documentation(i),
            properties: parse_properties(i)
          )
          @index[connection.id] = connection
          connection
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
