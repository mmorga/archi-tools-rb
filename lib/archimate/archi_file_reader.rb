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
        node["id"],
        node["name"],
        node["xsi:type"].sub("archimate:", ""),
        parse_documentation(node),
        parse_properties(node)
      )
    end

    # TODO: implement me
    def parse_organization(_model)
      {}
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
      model.css(Conversion::ArchiFileFormat::DIAGRAM_XPATHS.join(",")).css('element[xsi|type="archimate:ArchimateDiagramModel"]').each_with_object({}) do |i, a|
        a[i["id"]] = Model::Diagram.new(i["id"], i["name"]) do |dia|
          dia.documentation = parse_documentation(i)
          dia.properties = parse_properties(i)
          dia.children = parse_children(i)
          # TODO: This is a quick fix to permit diff/merge
          dia.element_references = model.css("folder[type=\"diagrams\"] [archimateElement]").each_with_object([]) { |i, a| a << i.attr("archimateElement") }
        end
      end
    end

    def parse_children(diagram_element)
      {}
    end
  end
end
