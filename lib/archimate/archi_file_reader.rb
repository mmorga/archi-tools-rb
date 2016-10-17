# frozen_string_literal: true
module Archimate
  class ArchiFileReader
    def self.read(archifile)
      reader = new
      reader.read(archifile)
    end

    def read(archifile)
      parse(Nokogiri::XML(File.read(archifile)))
    end

    def parse(doc)
      DataModel::Model.new(
        id: doc.root["id"],
        name: doc.root["name"],
        documentation: parse_documentation(doc.root, "purpose"),
        properties: parse_properties(doc.root),
        elements: parse_elements(doc.root),
        organization: parse_organization(doc.root),
        relationships: parse_relationships(doc.root),
        diagrams: parse_diagrams(doc.root)
      )
    end

    def parse_documentation(node, element_name = "documentation")
      node.css(">#{element_name}").each_with_object([]) { |i, a| a << i.content.strip }
    end

    def parse_properties(node)
      node.css(">property").each_with_object([]) do |i, a|
        a << DataModel::Property.new(key: i["key"], value: i["value"]) unless i["key"].nil?
      end
    end

    def parse_elements(model)
      model.css(Conversion::ArchiFileFormat::FOLDER_XPATHS.join(",")).css('element[id]').each_with_object({}) do |i, a|
        a[i["id"]] = parse_element(i)
      end
    end

    def parse_element(node)
      DataModel::Element.new(
        id: node["id"],
        label: node["name"],
        type: node["xsi:type"].sub("archimate:", ""),
        documentation: parse_documentation(node),
        properties: parse_properties(node)
      )
    end

    def parse_organization(model)
      DataModel::Organization.new(folders: parse_folders(model))
    end

    def parse_folders(node)
      Archimate.array_to_id_hash(
        node.css("> folder").each_with_object([]) { |i, a| a << parse_folder(i) }
      )
    end

    def parse_folder(node)
      DataModel::Folder.new(
        id: node.attr("id"),
        name: node.attr("name"),
        type: node.attr("type"),
        documentation: parse_documentation(node),
        properties: parse_properties(node),
        items: child_element_ids(node),
        folders: parse_folders(node)
      )
    end

    def child_element_ids(node)
      node.css(">element[id]").each_with_object([]) { |i, a| a << i.attr("id") }
    end

    def parse_relationships(model)
      model.css(Conversion::ArchiFileFormat::RELATION_XPATHS.join(",")).css("element").each_with_object({}) do |i, a|
        a[i["id"]] = DataModel::Relationship.new(
          id: i["id"],
          type: i.attr("xsi:type").sub("archimate:", ""),
          source: i.attr("source"),
          target: i.attr("target"),
          name: i["name"],
          documentation: parse_documentation(i),
          properties: parse_properties(i)
        )
      end
    end

    def parse_diagrams(model)
      model.css(Conversion::ArchiFileFormat::DIAGRAM_XPATHS.join(",")).css(
        'element[xsi|type="archimate:ArchimateDiagramModel"]'
      ).each_with_object({}) do |i, a|
        a[i["id"]] = DataModel::Diagram.new(
          id: i["id"],
          name: i["name"],
          viewpoint: i["viewpoint"],
          documentation: parse_documentation(i),
          properties: parse_properties(i),
          children: parse_children(i),
          connection_router_type: i["connectionRouterType"],
          type: i.attr("type"),
          # TODO: This is a quick fix to permit diff/merge
          element_references: i.css("[archimateElement]").each_with_object([]) do |i2, a2|
            a2 << i2["archimateElement"]
          end
        )
      end
    end

    def parse_children(node)
      Archimate.array_to_id_hash(
        node.css("> child").each_with_object([]) do |i, a|
          a << parse_child(i)
        end
      )
    end

    def parse_child(child_node)
      child_hash = {
        id: "id",
        type: "type",
        model: "model",
        name: "name",
        target_connections: "targetConnections",
        archimate_element: "archimateElement"
      }.each_with_object({}) do |(hash_attr, node_attr), a|
        a[hash_attr] = child_node.attr(node_attr) # if child_node.attributes.include?(node_attr)
      end
      child_hash[:bounds] = parse_bounds(child_node.at_css("> bounds"))
      child_hash[:children] = parse_children(child_node)
      child_hash[:source_connections] = parse_source_connections(child_node.css("> sourceConnection"))
      child_hash[:documentation] = parse_documentation(child_node)
      child_hash[:properties] = parse_properties(child_node)
      child_hash[:style] = parse_style(child_node)
      DataModel::Child.new(child_hash)
    end

    def parse_style(node)
      DataModel::Style.new(
        text_alignment: nil, # node["textAlignment"],
        fill_color: nil, # node["fillColor"],
        line_color: nil, # node["lineColor"],
        font_color: nil, # node["fontColor"],
        font: nil, # parse_font(node["font"])
        line_width: nil
      )
    end

    def parse_color(str)
      # TODO: implement me
      # DataModel::Color.from_css(str)
      nil
    end

    def parse_font(str)
      # TODO: implement me
      nil
    end

    def parse_bounds(node)
      DataModel::Bounds.new(
        x: node.attr("x"),
        y: node.attr("y"),
        width: node.attr("width"),
        height: node.attr("height")
      )
    end

    def parse_source_connections(nodes)
      nodes.each_with_object([]) do |i, a|
        a << DataModel::SourceConnection.new(
          id: i["id"],
          type: i.attr("xsi:type"),
          source: i["source"],
          target: i["target"],
          relationship: i["relationship"],
          name: i["name"],
          style: parse_style(i),
          bendpoints: parse_bendpoints(i.css("bendpoint")),
          documentation: parse_documentation(i),
          properties: parse_properties(i)
        )
      end
    end

    def parse_bendpoints(nodes)
      nodes.each_with_object([]) do |i, a|
        a << DataModel::Bendpoint.new(
          start_x: i.attr("startX"), start_y: i.attr("startY"),
          end_x: i.attr("endX"), end_y: i.attr("endY")
        )
      end
    end
  end
end
