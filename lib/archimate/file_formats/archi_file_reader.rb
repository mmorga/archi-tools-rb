# frozen_string_literal: true
require "nokogiri"

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

      def initialize
        @progress = nil
        @random ||= Random.new
      end

      def read(archifile)
        parse(Nokogiri::XML(archifile))
      end

      def parse(doc)
        @size = 0
        doc.traverse { |_n| @size += 1 }
        @progress = ProgressIndicator.new(total: @size, title: "Parsing")
        @property_defs = {}
        tick
        diagrams = parse_diagrams(doc.root)
        DataModel::Model.new(
          id: doc.root["id"],
          name: doc.root["name"],
          documentation: parse_documentation(doc.root, "purpose"),
          properties: parse_properties(doc.root),
          elements: parse_elements(doc.root),
          organizations: parse_organizations(doc.root),
          relationships: parse_relationships(doc.root),
          diagrams: diagrams,
          views: DataModel::Views.new(viewpoints: [], diagrams: diagrams),
          property_definitions: @property_defs.values,
          namespaces: {},
          schema_locations: []
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
          key = i["key"]
          next unless key
          if @property_defs.key?(key)
            prop_def = @property_defs[key]
          else
            @property_defs[key] = prop_def = DataModel::PropertyDefinition.new(
              id: DataModel::PropertyDefinition.identifier_for_key(key),
              name: key,
              documentation: [],
              value_type: "string"
            )
          end
          a << DataModel::Property.new(
            values: [
              DataModel::LangString.new(text: i["value"] || "en")
            ],
            property_definition_id: prop_def.id
          )
        end
      end

      def parse_elements(model)
        model.css(ArchiFileFormat::FOLDER_XPATHS.join(",")).css('element[id]').map do |i|
          tick
          DataModel::Element.new(
            id: i["id"],
            name: i["name"],
            organization_id: i.parent["id"],
            type: i["xsi:type"].sub("archimate:", ""),
            documentation: parse_documentation(i),
            properties: parse_properties(i)
          )
        end
      end

      def parse_organizations(node)
        node.css("> folder").each_with_object([]) do |i, a|
          tick
          a << DataModel::Organization.new(
            id: i.attr("id"),
            name: i.attr("name"),
            type: i.attr("type"),
            documentation: parse_documentation(i),
            properties: parse_properties(i),
            items: child_element_ids(i),
            organizations: parse_organizations(i)
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
            access_type: parse_access_type(i["accessType"]),
            documentation: parse_documentation(i),
            properties: parse_properties(i)
          )
        end
      end

      def parse_access_type(val)
        return nil unless val && val.size > 0
        i = val.to_i
        return nil unless i >= 0 && i < DataModel::AccessType.size
        DataModel::AccessType[i]
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
            nodes: parse_nodes(i),
            connections: parse_all_connections(i),
            connection_router_type: i["connectionRouterType"],
            type: i.attr("xsi:type"),
            background: i.attr("background")
          )
        end
      end

      def parse_nodes(node)
        node.css("> child").each_with_object([]) do |child_node, a|
          tick
          a << DataModel::ViewNode.new(
            id: child_node.attr("id"),
            type: child_node.attr("xsi:type"),
            model: child_node.attr("model"),
            name: child_node.attr("name"),
            target_connections: parse_target_connections(child_node.attr("targetConnections")),
            archimate_element: child_node.attr("archimateElement"),
            bounds: parse_bounds(child_node),
            nodes: parse_nodes(child_node),
            connections: parse_connections(child_node),
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

      def parse_all_connections(node)
        node.css("sourceConnection").each_with_object([]) do |i, a|
          tick
          a << parse_connection(i)
        end
      end

      def parse_connections(node)
        node.css("> sourceConnection").each_with_object([]) { |i, a| a << parse_connection(i) }
      end

      def parse_connection(i)
        DataModel::Connection.new(
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

      # startX = location.x - source_attachment.x
      # startY = location.y - source_attachment.y
      # endX = location.x - target_attachment.x
      # endY = location.y - source_attachment.y
      def parse_bendpoints(node)
        node.css("bendpoint").each_with_object([]) do |i, a|
          tick
          a << DataModel::Location.new(
            x: i.attr("startX") || 0, y: i.attr("startY") || 0,
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
