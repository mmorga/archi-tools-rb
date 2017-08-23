# frozen_string_literal: true
require "nokogiri"

module Archimate
  module FileFormats
    class ArchiFileReader < Reader
      FutureLookup = Struct.new(:obj, :attr, :id)

      def initialize(doc)
        super
        @futures = []
      end

      def parse_model(node)
        properties = parse_properties(node)
        elements = parse_elements(node)
        relationships = parse_relationships(node)
        diagrams = parse_diagrams(node)
        organizations = parse_organizations(node)
        model = DataModel::Model.new(
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
        )
        @futures.each do |future|
          future.obj.send(
            "#{future.attr}=".to_sym,
            case future.id
            when Array
              future.id.map { |id| index[id] }
            else
              index[future.id]
            end
          )
        end
        register(model)
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
          .filter('element')
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

      def parse_organization(i)
        tick
        organization = DataModel::Organization.new(
          id: i.attr("id"),
          name: DataModel::LangString.string(i["name"]),
          type: i.attr("type"),
          documentation: parse_documentation(i),
          # properties: parse_properties(i),
          items: [],
          organizations: parse_organizations(i)
        )
        @futures << FutureLookup.new(organization, :items, organization_items(i))
        register(organization)
      end

      def organization_items(node)
        node
          .children
          .filter("element").map do |i, a|
          tick
          i.attr("id")
        end
      end

      def relationship_nodes(model)
        model
          .css(ArchiFileFormat::RELATION_XPATHS.join(","))
          .children
          .filter("element")
      end

      def parse_relationship(i)
        tick
        relationship = DataModel::Relationship.new(
          id: i["id"],
          type: i.attr("xsi:type").sub("archimate:", ""),
          source: nil,
          target: nil,
          name: DataModel::LangString.string(i["name"]),
          access_type: parse_access_type(i["accessType"]),
          documentation: parse_documentation(i),
          properties: parse_properties(i)
        )
        @futures << FutureLookup.new(relationship, :source, i.attr("source"))
        @futures << FutureLookup.new(relationship, :target, i.attr("target"))
        register(relationship)
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

      def parse_view_node(child_node)
        tick
        view_node = register(DataModel::ViewNode.new(
          id: child_node.attr("id"),
          type: child_node.attr("xsi:type"),
          view_refs: nil,
          name: DataModel::LangString.string(child_node["name"]),
          element: nil,
          bounds: parse_bounds(child_node),
          nodes: [],
          connections: [],
          documentation: parse_documentation(child_node),
          properties: parse_properties(child_node),
          style: parse_style(child_node),
          content: child_node.at_css("> content")&.text,
          child_type: child_node.attr("type"),
          diagram: @diagram_stack.last
        ))
        @futures << FutureLookup.new(view_node, :view_refs, child_node.attr("model"))
        @futures << FutureLookup.new(view_node, :element, child_node.attr("archimateElement"))
        @futures << FutureLookup.new(view_node, :connections, parse_child_connections(child_node))
        view_node.nodes = parse_view_nodes(child_node)
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
        bounds = node.children.filter("bounds").first
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
          .children
          .filter("sourceConnection")
      end

      def parse_connection(i)
        tick
        connection = register(DataModel::Connection.new(
          id: i["id"],
          type: i.attr("xsi:type"),
          source: nil,
          target: nil,
          relationship: nil,
          name: i["name"],
          style: parse_style(i),
          bendpoints: parse_bendpoints(i),
          documentation: parse_documentation(i),
          properties: parse_properties(i)
        ))
        @futures << FutureLookup.new(connection, :source, i.attr("source"))
        @futures << FutureLookup.new(connection, :target, i.attr("target"))
        @futures << FutureLookup.new(connection, :relationship, i.attr("relationship"))
        connection
      end

      # startX = location.x - source_attachment.x
      # startY = location.y - source_attachment.y
      # endX = location.x - target_attachment.x
      # endY = location.y - source_attachment.y
      def parse_bendpoints(node)
        node
          .children
          .filter("bendpoint")
          .map do |i|
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
