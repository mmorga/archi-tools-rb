# frozen_string_literal: true
module Archimate
  class Document
    attr_accessor :doc

    XPATHS = {
      archimate: {
        elements: "/xmlns:model/xmlns:elements/xmlns:element",
        element_types: "/xmlns:model/xmlns:elements/xmlns:element/@xsi:type",
        elements_of_type: "/xmlns:model/xmlns:elements/xmlns:element[@xsi:type=\"%s\"]",
        child_labels: "./xmlns:label",
        element_with_id: "//xmlns:element[@identifier=\"%s\"]",
        attribute_with_value: "//*[@*=\"%s\"]",
        identifier: "identifier"
      },
      archi: {
        elements: "//element",
        element_types: "//element/@xsi:type",
        elements_of_type: "//element[@xsi:type=\"archimate:%s\"]",
        child_labels: "./@name",
        element_with_id: "//element[@id=\"%s\"]",
        attribute_with_value: "//*[@*=\"%s\"]",
        identifier: "id"
      }
    }.freeze

    FILE_TYPES = {
      "http://www.archimatetool.com/archimate" => :archi,
      "http://www.opengroup.org/xsd/archimate" => :archimate
    }.freeze

    def self.parent_for_node_type(node, doc)
      doc.at_xpath(ELEMENT_TYPE_TO_PARENT_XPATH[node["xsi:type"]])
    end

    def self.add_node_to_doc(node, doc)
      parent_for_node_type(node, doc) << node
    end

    def initialize(filename, options = {})
      opts = { verbose: false, output_io: $stdout }.merge(options)
      @filename = filename
      @doc = nil
      @file_type = nil

      @output = opts[:output_io]
      @verbose = opts[:verbose]
    end

    def self.read(filename)
      document = new(filename)
      document.read
      document
    end

    def identifier
      @doc.root["id"]
    end

    def xpath_for(sym)
      XPATHS[@file_type][sym]
    end

    def element_type_names
      names = @doc.xpath(xpath_for(:element_types)).map { |node| node.to_s.gsub("archimate:", "") }.uniq
      if @file_type == :archi
        names = names.reject do |name|
          %w(AccessRelationship AggregationRelationship
             AssignmentRelationship AssociationRelationship CompositionRelationship
             FlowRelationship InfluenceRelationship RealisationRelationship
             SpecialisationRelationship TriggeringRelationship UsedByRelationship
             ArchimateDiagramModel SketchModel).include?(name)
        end
      end

      # TODO: Handle renaming Junctions
      names = names.reject { |name| %w(Junction AndJunction OrJunction).include?(name) }
      names
    end

    def elements
      @doc.xpath(xpath_for(:elements))
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

    def element_type(node)
      el_type = node.attribute("type").to_s
      el_type = el_type.gsub("archimate:", "") if @file_type == :archi
      el_type
    end

    def model_elements
      @model_elements ||= report_size("Evaluating %s elements", @doc.css(Archimate::Conversion::ArchiFileFormat::FOLDER_XPATHS.join(",")).css('element[id]'))
    end

    def model_set
      @model_set ||= report_size(
        "Found %s model items",
        Set.new(model_elements.each_with_object([]) { |i, a| a << i.attr("id") })
      )
    end

    def diagrams_folder
      @diagrams_folder ||= doc.css(DIAGRAM_XPATHS.join(","))
    end

    def relation_ref_ids
      @relation_ref_ids ||= Set.new(
        diagrams_folder.css("[relationship]").each_with_object([]) { |i, a| a << i.attr("relationship") }
      )
    end

    def relations_folders
      @relations_folder ||= doc.css(Conversion::ArchiFileFormat::RELATION_XPATHS.join(","))
    end

    def relation_ids
      @relation_ids ||= Set.new(relations_folders.css("element[id]").each_with_object([]) { |i, a| a << i.attr("id") })
    end

    def relationships
      relations_folders.css("element")
    end

    def ref_set
      @ref_set ||= report_size(
        "Found references to %s items",
        Set.new(
          relations_folders.css("element[source],element[target]").each_with_object(
            diagrams_folder.css("[archimateElement]").each_with_object([]) { |i, a| a << i.attr("archimateElement") }
          ) { |i, a| a << i.attr("source") << i.attr("target") }
        )
      )
    end

    def unref_set
      @unref_set ||= model_set - ref_set
    end

    def unrefed_ids
      @unrefed_ids ||= unref_set + (relation_ids - relation_ref_ids)
    end

    # TODO: Add things like containing Folder, description of children, etc.
    def stringize(node)
      "#{element_type(node)} #{element_identifier(node)} #{node.elements.size} children"
    end

    def layer(node)
      return nil if node&.document?
      # TODO: test for Archi format and archimate open exchange format
      if node.name == "folder" && !node["type"].nil?
        node["type"]
      else
        layer(node.parent)
      end
    end

    def model
      @model ||= Model::Model.new(doc.root)
    end

    def save_as(filename)
      File.open(filename, "w") do |f|
        f.write(@doc)
      end
    end

    def read
      @doc = Nokogiri::XML(File.open(@filename))
      namespace = @doc.root.namespace.href
      # $stderr.write "Unknown file type: #{namespace} in '#{@filename}'"
      raise "Unknown file type: #{namespace}" unless FILE_TYPES.include? namespace

      @file_type = FILE_TYPES[namespace]
      # TODO: disable this - this is for debugging only
      # outfile = "original.xml"
      # File.open(outfile, "w") do |f|
      #   f.write(@doc)
      # end
    end

    def report_size(str, collection)
      # TODO: convert to error_helper module
      @output.puts format(str, collection.size) if @verbose
      collection
    end
  end
end
