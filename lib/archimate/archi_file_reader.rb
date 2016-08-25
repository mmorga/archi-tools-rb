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
        doc.root["name"],
        parse_documentation(doc.root, "purpose"),
        parse_properties(doc.root),
        parse_elements(doc.root),
        parse_organization(doc.root),
        parse_relationships(doc.root)
      ).freeze
      # TODO: diagrams
    end

    def parse_documentation(node, element_name = "documentation")
      node.css(">#{element_name}").each_with_object([]) { |i, a| a << i.content.strip }
    end

    def parse_properties(node)
      node.css(">property").each_with_object([]) { |i, a| a << Model::Property.new(i) }
    end

    def parse_elements(model)
      model.css(Conversion::ArchiFileFormat::FOLDER_XPATHS.join(",")).css('element[id]').each_with_object({}) do |i, a|
        a[i["id"]] = Model::Element.new(
          i["id"],
          i["name"],
          i["xsi:type"].sub("archimate:", ""),
          parse_documentation(i),
          parse_properties(i)
        )
      end
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
          i["name"],
          parse_documentation(i),
          parse_properties(i)
        )
      end
    end
  end
end
