# frozen_string_literal: true
require "nokogiri"

module Archimate
  module FileFormats
    class ArchiFileReader < Reader
      def initialize(doc)
        super
      end

      def parse_model(node)
        properties = parse_properties(node)
        elements = parse_elements(node)
        relationships = parse_relationships(node)
        diagrams = parse_diagrams(node)
        organizations = parse_organizations(node)
        register(DataModel::Model.new(
          id: node["id"],
          name: DataModel::LangString.string(node["name"]),
          documentation: parse_documentation(node, "purpose"),
          properties: properties,
          elements: elements,
          organizations: organizations,
          relationships: relationships,
          diagrams: diagrams,
          viewpoints: [],
          property_definitions: @property_defs.values,
          namespaces: {},
          schema_locations: []
        ))
      end

      def properties_selector
        ">property"
      end

      def parse_property(i)
        tick
        key = i["key"]
        return nil unless key
        if @property_defs.key?(key)
          prop_def = @property_defs[key]
        else
          @property_defs[key] = prop_def = register(DataModel::PropertyDefinition.new(
            id: DataModel::PropertyDefinition.identifier_for_key(key),
            name: DataModel::LangString.string(key),
            documentation: nil,
            type: "string"
          ))
        end
        DataModel::Property.new(
          value: DataModel::LangString.string(i["value"]),
          property_definition: prop_def
        )
      end

      def element_nodes(model)
        model
          .css(ArchiFileFormat::FOLDER_XPATHS.join(","))
          .css('element[id]')
      end

      def parse_element(i)
        tick
        register(DataModel::Element.new(
          id: i["id"],
          name: DataModel::LangString.string(i["name"]),
          type: i["xsi:type"].sub("archimate:", ""),
          documentation: parse_documentation(i),
          properties: parse_properties(i)
        ))
      end

      def organizations_selector
        "> folder"
      end

      def parse_organization(i)
        tick
        register(DataModel::Organization.new(
          id: i.attr("id"),
          name: DataModel::LangString.string(i["name"]),
          type: i.attr("type"),
          documentation: parse_documentation(i),
          # properties: parse_properties(i),
          items: organization_items(i),
          organizations: parse_organizations(i)
        ))
      end

      def organization_items(node)
        node.css(">element[id]").map do |i, a|
          tick
          lookup_or_parse(i.attr("id"))
        end
      end

      def relationship_nodes(model)
        model
          .css(ArchiFileFormat::RELATION_XPATHS.join(","))
          .css("element")
      end

      def parse_relationship(i)
        tick
        register(DataModel::Relationship.new(
          id: i["id"],
          type: i.attr("xsi:type").sub("archimate:", ""),
          source: lookup_or_parse(i.attr("source")),
          target: lookup_or_parse(i.attr("target")),
          name: DataModel::LangString.string(i["name"]),
          access_type: parse_access_type(i["accessType"]),
          documentation: parse_documentation(i),
          properties: parse_properties(i)
        ))
      end

      def parse_access_type(val)
        return nil unless val && val.size > 0
        i = val.to_i
        return nil unless (0..DataModel::ACCESS_TYPE.size-1).include?(i)
        DataModel::ACCESS_TYPE[i]
      end

      def diagram_nodes(model)
        model
          .css(ArchiFileFormat::DIAGRAM_XPATHS.join(","))
          .css(
            'element[xsi|type="archimate:ArchimateDiagramModel"]',
            'element[xsi|type="archimate:SketchModel"]'
          )
      end

      def parse_diagram(i)
        tick
        diagram = register(DataModel::Diagram.new(
          id: i["id"],
          name: DataModel::LangString.string(i["name"]),
          viewpoint_type: parse_viewpoint_type(i["viewpoint"]),
          viewpoint: nil,
          documentation: parse_documentation(i),
          properties: parse_properties(i),
          nodes: [], # parse_view_nodes(i),
          connections: [], # parse_connections(i),
          connection_router_type: i["connectionRouterType"],
          type: i.attr("xsi:type"),
          background: i.attr("background")
        ))
        @diagram_stack.push(diagram)
        diagram.nodes = parse_view_nodes(i)
        diagram.connections = parse_connections(i)
        @diagram_stack.pop
      end

      def parse_viewpoint_type(viewpoint_idx)
        return nil unless viewpoint_idx
        viewpoint_idx = viewpoint_idx.to_i
        return nil if viewpoint_idx.nil?
        ArchiFileFormat::VIEWPOINTS[viewpoint_idx]
      end

      def view_nodes_selector
        "> child"
      end

      def parse_view_node(child_node)
        tick
        raise "Hell #{@diagram_stack.last.inspect}" unless @diagram_stack.last.is_a?(Archimate::DataModel::Diagram)
        view_node = register(DataModel::ViewNode.new(
          id: child_node.attr("id"),
          type: child_node.attr("xsi:type"),
          view_refs: nil, #  lookup_or_parse(child_node.attr("model")),
          name: DataModel::LangString.string(child_node["name"]),
          element: nil, # lookup_or_parse(child_node.attr("archimateElement")),
          bounds: parse_bounds(child_node),
          nodes: [], # parse_view_nodes(child_node),
          connections: [], # parse_child_connections(child_node),
          documentation: parse_documentation(child_node),
          properties: parse_properties(child_node),
          style: parse_style(child_node),
          content: child_node.at_css("> content")&.text,
          child_type: child_node.attr("type"),
          diagram: @diagram_stack.last
        ))
        view_node.view_refs = lookup_or_parse(child_node.attr("model"))
        view_node.element = lookup_or_parse(child_node.attr("archimateElement"))
        view_node.nodes = parse_view_nodes(child_node)
        view_node.connections = parse_child_connections(child_node)
        view_node
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

      def connections_selector
        "sourceConnection"
      end

      # TODO: Eliminate the need for this
      def parse_child_connections(node)
        node
          .css("> sourceConnection")
          .map { |i| lookup_or_parse(i) }
      end

      def parse_connection(i)
        tick
        connection = register(DataModel::Connection.new(
          id: i["id"],
          type: i.attr("xsi:type"),
          source: nil, # lookup_or_parse(i["source"]),
          target: nil, # lookup_or_parse(i["target"]),
          relationship: nil, # lookup_or_parse(i["relationship"]),
          name: i["name"],
          style: parse_style(i),
          bendpoints: parse_bendpoints(i),
          documentation: parse_documentation(i),
          properties: parse_properties(i)
        ))
        connection.source = lookup_or_parse(i["source"])
        connection.target = lookup_or_parse(i["target"])
        connection.relationship = lookup_or_parse(i["relationship"])
        connection
      end

      # startX = location.x - source_attachment.x
      # startY = location.y - source_attachment.y
      # endX = location.x - target_attachment.x
      # endY = location.y - source_attachment.y
      def parse_bendpoints(node)
        node.css("bendpoint").map do |i|
          tick
          DataModel::Location.new(
            x: i.attr("startX") || 0, y: i.attr("startY") || 0,
            end_x: i.attr("endX"), end_y: i.attr("endY")
          )
        end
      end

      def lookup_or_parse(id_or_node)
        return nil unless id_or_node
        id = id_or_node.is_a?(String) ? id_or_node : id_or_node["id"]
        return nil if id.empty?
        ref = index[id]
        return ref if ref
        node = @doc.at_css("*[id=\"#{id}\"]")
        return nil unless node
        # puts "Parsing a node #{node.name} (#{node.attributes.map { |k, v| "#{k}=#{v}" }.join(", ")})"
        case(node.name)
        when "sourceConnection"
          register(parse_connection(node))
        when "folder"
          register(parse_organization(node))
        when "model"
          register(parse_model(node))
        when "child"
          register(parse_view_node(node))
        when "element"
          case(node["xsi:type"].sub("archimate:", ""))
          when "ArchimateDiagramModel", "SketchModel"
            register(parse_diagram(node))
          when /Relationship$/
            register(parse_relationship(node))
          else
            register(parse_element(node))
          end
        else
          nil
        end
      end
    end
  end
end
