require "nokogiri"

module Archimate
  class Document
    XPATHS = {
      archimate: {
        element_types: "/xmlns:model/xmlns:elements/xmlns:element/@xsi:type",
        elements_of_type: "/xmlns:model/xmlns:elements/xmlns:element[@xsi:type=\"%s\"]",
        child_labels: "./xmlns:label",
        element_with_id: "//xmlns:element[@identifier=\"%s\"]",
        attribute_with_value: "//*[@*=\"%s\"]",
        identifier: "identifier"
      },
      archi: {
        element_types: "//element/@xsi:type",
        elements_of_type: "//element[@xsi:type=\"archimate:%s\"]",
        child_labels: "./@name",
        element_with_id: "//element[@id=\"%s\"]",
        attribute_with_value: "//*[@*=\"%s\"]",
        identifier: "id"
      }
    }

    FILE_TYPES = {
      "http://www.archimatetool.com/archimate".freeze => :archi,
      "http://www.opengroup.org/xsd/archimate".freeze => :archimate
    }

    def initialize(filename)
      @filename = filename
      @doc = nil
      @file_type = nil
    end

    def self.read(filename)
      document = self.new(filename)
      document.read
      document
    end

    def xpath_for(sym)
      XPATHS[@file_type][sym]
    end

    def element_type_names()
      names = @doc.xpath(xpath_for(:element_types)).map {|node| node.to_s.gsub("archimate:", "")}.uniq
      if @file_type == :archi
        names = names.reject {|name| %w(AccessRelationship AggregationRelationship
          AssignmentRelationship AssociationRelationship CompositionRelationship
          FlowRelationship InfluenceRelationship RealisationRelationship
          SpecialisationRelationship TriggeringRelationship UsedByRelationship
          ArchimateDiagramModel SketchModel).include?(name)}
      end

      # TODO: Handle renaming Junctions
      names = names.reject {|name| %w(Junction AndJunction OrJunction).include?(name)}
      names
    end

    def elements_with_type(element_type)
      @doc.xpath(format(xpath_for(:elements_of_type), element_type))
    end

    def elements_with_attribute_value(val)
      @doc.xpath(format(xpath_for(:attribute_with_value), val))
    end

    def element_by_identifier(identifier)
      @doc.at_xpath(format(xpath_for(:element_with_id), identifier))
    end

    def element_identifier(node)
      node.attr(xpath_for(:identifier).to_s)
    end

    def element_label(node)
      if @file_type == :archimate
        label_el = node.at_xpath(xpath_for(:child_labels))
        label_el.nil? ? "" : label_el.content.to_s
      elsif @file_type == :archi
        node.key?("name") ? node.attribute("name").value : ""
      end
    end

    def save_as(filename)
      File.open(filename, "w") do |f|
        f.write(@doc)
      end
    end

    def read()
      @doc = Nokogiri::XML(File.open(@filename))
      namespace = @doc.root.namespace.href
      raise "Unknown file type: #{namespace}" unless FILE_TYPES.include? namespace
      @file_type = FILE_TYPES[namespace]
      # TODO: disable this - this is for debugging only
      outfile = "original.xml"
      File.open(outfile, "w") do |f|
        f.write(@doc)
      end
    end
  end
end
