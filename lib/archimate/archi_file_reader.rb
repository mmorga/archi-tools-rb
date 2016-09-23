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
      Model::Model.new(
        doc.root["id"],
        doc.root["name"]
      ) do |model|
        model.documentation = parse_documentation(doc.root, "purpose")
        model.properties = parse_properties(doc.root)
        model.elements = parse_elements(doc.root)
        model.organization = parse_organization(doc.root)
        model.relationships = parse_relationships(doc.root)
        model.diagrams = parse_diagrams(doc.root)
      end
    end

    def parse_documentation(node, element_name = "documentation")
      node.css(">#{element_name}").each_with_object([]) { |i, a| a << i.content.strip }
    end

    def parse_properties(node)
      node.css(">property").each_with_object([]) { |i, a| a << Model::Property.new(i["key"], i["value"]) }
    end

    def parse_elements(model)
      model.css(Conversion::ArchiFileFormat::FOLDER_XPATHS.join(",")).css('element[id]').each_with_object({}) do |i, a|
        a[i["id"]] = parse_element(i)
      end
    end

    def parse_element(node)
      Model::Element.new(
        id: node["id"],
        label: node["name"],
        type: node["xsi:type"].sub("archimate:", ""),
        documentation: parse_documentation(node),
        properties: parse_properties(node)
      )
    end

    def parse_organization(model)
      Model::Organization.new(parse_folders(model))
    end

    def parse_folders(node)
      Archimate.array_to_id_hash(
        node.css("> folder").each_with_object([]) { |i, a| a << parse_folder(i) }
      )
    end

    def parse_folder(node)
      Model::Folder.new(
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
        a[i["id"]] = Model::Relationship.new(
          i["id"],
          i.attr("xsi:type").sub("archimate:", ""),
          i.attr("source"),
          i.attr("target"),
          i["name"]
        ) do |rel|
          rel.documentation = parse_documentation(i)
          rel.properties = parse_properties(i)
        end
      end
    end

    def parse_diagrams(model)
      model.css(Conversion::ArchiFileFormat::DIAGRAM_XPATHS.join(",")).css(
        'element[xsi|type="archimate:ArchimateDiagramModel"]'
      ).each_with_object({}) do |i, a|
        a[i["id"]] = Model::Diagram.new(
          id: i["id"],
          name: i["name"],
          viewpoint: i["viewpoint"],
          documentation: parse_documentation(i),
          properties: parse_properties(i),
          children: parse_children(i),
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
        text_alignment: "textAlignment",
        fill_color: "fillColor",
        model: "model",
        name: "name",
        target_connections: "targetConnections",
        archimate_element: "archimateElement",
        font: "font",
        line_color: "lineColor",
        font_color: "fontColor"
      }.each_with_object({}) do |(hash_attr, node_attr), a|
        a[hash_attr] = child_node.attr(node_attr) # if child_node.attributes.include?(node_attr)
      end
      child_hash[:bounds] = parse_bounds(child_node.at_css("> bounds"))
      child_hash[:children] = parse_children(child_node)
      child_hash[:source_connections] = parse_source_connections(child_node.css("> sourceConnection"))
      Model::Child.new(child_hash)
    end

    def parse_bounds(node)
      Model::Bounds.new(
        x: node.attr("x"),
        y: node.attr("y"),
        width: node.attr("width"),
        height: node.attr("height"))
    end

    def parse_source_connections(nodes)
      nodes.each_with_object([]) do |i, a|
        a << Model::SourceConnection.new(i["id"]) do |sc|
          [
            [:type=, "xsi:type"],
            [:source=, "source"],
            [:target=, "target"],
            [:relationship=, "relationship"]
          ].each do |attr_setter, attr_name|
            sc.send(attr_setter, i.attr(attr_name)) if i.attributes.include?(attr_name)
          end

          sc.bendpoints = parse_bendpoints(i.css("bendpoint"))
        end
      end
    end

    def parse_bendpoints(nodes)
      nodes.each_with_object([]) do |i, a|
        a << Model::Bendpoint.new(
          start_x: i.attr("startX"), start_y: i.attr("startY"),
          end_x: i.attr("endX"), end_y: i.attr("endY")
        )
      end
    end
  end
end
