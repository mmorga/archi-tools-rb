# frozen_string_literal: true
require "nokogiri"

module Archimate
  module FileFormats
    class ModelExchangeFileReader
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

      def self.parse(model_exchange_io)
        new.parse(model_exchange_io)
      end

      def parse(model_exchange_io)
        root = Nokogiri::XML(model_exchange_io)&.root
        return nil if root.nil?
        parse_model(root)
      end

      def archimate_3?
        return @archimate_version == :archimate_3_0
      end

      def parse_model(root)
        @archimate_version = parse_archimate_version(root)
        org_sel = archimate_3? ? ">organizations" : ">organization>item"
        DataModel::Model.new(
          index_hash: {},
          id: identifier_to_id(root["identifier"]),
          name: parse_lang_string(root.at_css(">name")),
          version: root["version"],
          metadata: parse_metadata(root),
          documentation: parse_documentation(root),
          properties: parse_properties(root),
          elements: parse_elements(root),
          relationships: parse_relationships(root),
          organizations: parse_organizations(root.css(org_sel)),
          diagrams: parse_diagrams(root),
          viewpoints: [],
          property_definitions: parse_property_defs(root),
          schema_locations: root.attr("xsi:schemaLocation").split(" "),
          namespaces: root.namespaces,
          archimate_version: @archimate_version
        )
      end

      def parse_metadata(root)
        metadata = root.at_css(">metadata")
        return nil unless metadata
        DataModel::Metadata.new(schema_infos: parse_schema_infos(metadata))
      end

      def parse_schema_infos(metadata)
        schema_infos = metadata.css(">schemaInfo")
        if schema_infos.size > 0
          schema_infos.map { |si| parse_schema_info(si) }
        else
          [parse_schema_info(metadata)].compact
        end
      end

      def parse_schema_info(node)
        els = node.element_children
        return nil if els.empty?
        schema_info_attrs = {
          schema: nil,
          schemaversion: nil,
          elements: []
        }
        els.each do |el|
          case(el.name)
          when "schema"
            schema_info_attrs[:schema] = el.text
          when "schemaversion"
            schema_info_attrs[:schemaversion] = el.text
          else
            schema_info_attrs[:elements] << parse_any_element(el)
          end
        end
        DataModel::SchemaInfo.new(schema_info_attrs)
      end

      def parse_any_element(node)
        return nil unless node && node.is_a?(Nokogiri::XML::Element)
        DataModel::AnyElement.new(
          element: node.name,
          prefix: node.namespace&.prefix,
          attributes: node.attributes.map { |attr| parse_any_attribute(attr) },
          content: node.text,
          children: node.element_children.map { |child| parse_any_element(node) }
        )
      end

      def parse_any_attribute(attr)
        DataModel::AnyAttribute.new(
          attribute: attr.name,
          prefix: attr.namepace&.prefix,
          value: attr.text
        )
      end

      def parse_archimate_version(root)
        case root.namespace.href
        when "http://www.opengroup.org/xsd/archimate"
          :archimate_2_1
        else # assuming: "http://www.opengroup.org/xsd/archimate/3.0/"
          :archimate_3_0
        end
      end

      def property_defs_selector
        if archimate_3?
          ">propertyDefinitions>propertyDefinition"
        else
          ">propertydefs>propertydef"
        end
      end

      def parse_property_defs(node)
        if archimate_3?
          parse_property_defs_30(node)
        else
          parse_property_defs_21(node)
        end
      end

      def parse_property_defs_21(node)
        node.css(property_defs_selector).map do |i|
          DataModel::PropertyDefinition.new(
            id: i["identifier"],
            name: DataModel::LangString.new(text: i["name"]),
            documentation: parse_documentation(i),
            value_type: i["type"]
          )
        end
      end

      def parse_property_defs_30(node)
        node.css(property_defs_selector).map do |i|
          DataModel::PropertyDefinition.new(
            id: i["identifier"],
            name: parse_lang_string(i.at_css("name")),
            documentation: parse_documentation(i),
            value_type: i["type"]
          )
        end
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
        value_node = node.at_css("value")
        lang = value_node.nil? ? "en" : value_node["xml:lang"]
        value = value_node&.content
        DataModel::Property.new(
          # TODO: This is one case where version 2.1 differs from version 3.0
          property_definition_id: node.attr("identifierref") || node.attr("propertyDefinitionRef"),
          values: [
            DataModel::LangString.new(text: value, lang: lang)
          ]
        )
      end

      def parse_elements(model)
        model.css(">elements>element").map do |i|
          name = parse_lang_string(i.at_css(">label") || i.at_css(">name"))
          DataModel::Element.new(
            id: identifier_to_id(i["identifier"]),
            name: name,
            type: i["xsi:type"],
            documentation: parse_documentation(i),
            properties: parse_properties(i)
          )
        end
      end

      def parse_lang_string(node)
        return nil unless node
        DataModel::LangString.new(text: node.content, lang: node["xml:lang"])
      end

      def parse_organizations(nodes)
        nodes.map do |i|
          child_items = i.css(">item")
          identifier_ref_name = archimate_3? ? "identifierRef" : "identifierref"
          ref_items = child_items.select { |ci| ci.has_attribute?(identifier_ref_name) }
          DataModel::Organization.new(
            id: i["identifier"], # TODO: model exchange doesn't assign ids to organization items
            name: parse_lang_string(i.at_css(">label")),
            documentation: parse_documentation(i),
            items: ref_items.map { |ri| identifier_to_id(ri[identifier_ref_name]) },
            organizations: parse_organizations(child_items.reject { |ci| ci.has_attribute?(identifier_ref_name) })
          )
        end
      end

      def child_element_ids(node)
        node.css(">element[id]").map { |i| i.attr("id") }
      end

      def parse_relationships(model)
        model.css(">relationships>relationship").map do |i|
          name = parse_lang_string(i.at_css(">label") || i.at_css(">name"))
          DataModel::Relationship.new(
            id: identifier_to_id(i["identifier"]),
            type: i.attr("xsi:type"),
            source: identifier_to_id(i.attr("source")),
            target: identifier_to_id(i.attr("target")),
            name: name,
            access_type: i["accessType"],
            documentation: parse_documentation(i),
            properties: parse_properties(i)
          )
        end
      end

      def parse_diagrams(model)
        model.css(">views>view").map do |i|
          nodes = parse_nodes(i)
          connections = parse_connections(i)
          child_id_hash = nodes.each_with_object({}) { |i2, a| a.merge!(i2.child_id_hash) }
          connections.each do |c|
            child_id_hash[c.source].connections << c
          end
          DataModel::Diagram.new(
            id: identifier_to_id(i["identifier"]),
            name: parse_lang_string(i.at_css("label")),
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
            type: i["type"],
            model: nil,
            name: parse_lang_string(i.at_css(">label")),
            target_connections: [], # TODO: needed? "targetConnections",
            archimate_element: identifier_to_id(i["elementref"]),
            bounds: parse_bounds(i),
            nodes: parse_nodes(i),
            connections: parse_connections(i),
            documentation: parse_documentation(i),
            properties: parse_properties(i),
            style: parse_style(i),
            content: i.at_css("> content")&.text,
            child_type: nil # i.attr("type")
          )
        end
      end

      def parse_style(node)
        style = node.at_css(">style")
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

      def style_to_int(str)
        case str
        when nil
          0
        when "italic"
          1
        when "bold"
          2
        when "bold|italic"
          3
        else
          raise "Broken for value: #{str}"
        end
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
            type: nil, # i.attr("xsi:type"),
            source: identifier_to_id(i["source"]),
            target: identifier_to_id(i["target"]),
            relationship: identifier_to_id(i["relationshipref"]),
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
