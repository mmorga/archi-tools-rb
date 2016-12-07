# frozen_string_literal: true
require "nokogiri"

module Archimate
  module FileFormats
    class ModelExchangeFileReader
      def self.parse(model_exchange_io)
        new.parse(model_exchange_io)
      end

      def parse(model_exchange_io)
        root = Nokogiri::XML(model_exchange_io)&.root
        return nil if root.nil?
        @property_defs = parse_property_defs(root)
        parse_model(root)
      end

      def parse_model(root)
        DataModel::Model.new(
          index_hash: {},
          id: identifier_to_id(root["identifier"]),
          name: parse_name(root),
          documentation: parse_documentation(root),
          properties: parse_properties(root),
          elements: parse_elements(root),
          relationships: parse_relationships(root),
          folders: parse_folders(root.css(">organization>item")),
          diagrams: parse_diagrams(root)
        )
      end

      def parse_property_defs(node)
        node.css(">propertydefs>propertydef").each_with_object({}) do |i, a|
          a[i["identifier"]] = { key: i["name"], type: i["type"] }
        end
      end

      def parse_name(node)
        name_node = node.at_css(">name")
        name_node.content unless name_node.nil?
      end

      def parse_documentation(node, element_name = "documentation")
        node.css(">#{element_name}").map do |i|
          DataModel::Documentation.new(text: i.content, lang: i.attr("lang"))
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
          key: @property_defs[node["identifierref"]][:key],
          value: value,
          lang: lang
        )
      end

      def parse_elements(model)
        model.css(">elements>element").map do |i|
          label = i.at_css(">label")
          DataModel::Element.new(
            id: identifier_to_id(i["identifier"]),
            label: label&.content,
            type: i["xsi:type"],
            documentation: parse_documentation(i),
            properties: parse_properties(i)
          )
        end
      end

      def parse_folders(nodes)
        nodes.map do |i|
          child_items = i.css(">item")
          ref_items = child_items.select { |ci| ci.has_attribute?("identifierref") }
          DataModel::Folder.new(
            id: i.at_css(">label")&.content, # TODO: model exchange doesn't assign ids to folder items
            name: i.at_css(">label")&.content,
            type: nil,
            documentation: parse_documentation(i),
            properties: parse_properties(i),
            items: ref_items.map { |ri| identifier_to_id(ri["identifierref"]) },
            folders: parse_folders(child_items.reject { |ci| ci.has_attribute?("identifierref") })
          )
        end
      end

      def child_element_ids(node)
        node.css(">element[id]").map { |i| i.attr("id") }
      end

      def parse_relationships(model)
        model.css(">relationships>relationship").map do |i|
          label = i.at_css(">label")
          DataModel::Relationship.new(
            id: identifier_to_id(i["identifier"]),
            type: i.attr("xsi:type"),
            source: identifier_to_id(i.attr("source")),
            target: identifier_to_id(i.attr("target")),
            name: label&.content,
            access_type: i["accessType"],
            documentation: parse_documentation(i),
            properties: parse_properties(i)
          )
        end
      end

      def parse_diagrams(model)
        model.css(">views>view").map do |i|
          children = parse_children(i)
          connections = parse_source_connections(i)
          child_id_hash = children.each_with_object({}) { |i2, a| a.merge!(i2.child_id_hash) }
          connections.each do |c|
            child_id_hash[c.source].source_connections << c
          end
          DataModel::Diagram.new(
            id: identifier_to_id(i["identifier"]),
            name: i.at_css("label")&.content,
            viewpoint: i["viewpoint"],
            documentation: parse_documentation(i),
            properties: parse_properties(i),
            children: children,
            connection_router_type: i["connectionRouterType"],
            type: i.attr("xsi:type"),
            background: i.attr("background")
          )
        end
      end

      def parse_children(node)
        node.css("> node").map do |i|
          DataModel::Child.new(
            id: identifier_to_id(i["identifier"]),
            type: i["type"],
            model: nil,
            name: i.at_css(">label")&.content,
            target_connections: [], # TODO: needed? "targetConnections",
            archimate_element: identifier_to_id(i["elementref"]),
            bounds: parse_bounds(i),
            children: parse_children(i),
            source_connections: parse_source_connections(i),
            documentation: parse_documentation(i),
            properties: parse_properties(i),
            style: parse_style(i),
            content: i.at_css("> content")&.text,
            child_type: nil  # i.attr("type")
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

      def parse_source_connections(node)
        node.css("> connection").map do |i|
          DataModel::SourceConnection.new(
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
          DataModel::Bendpoint.new(
            start_x: i.attr("x"), start_y: i.attr("y"),
            end_x: nil, end_y: nil
          )
        end
      end

      def identifier_to_id(str)
        str.sub(/^id-/, "") unless str.nil?
      end
    end
  end
end
