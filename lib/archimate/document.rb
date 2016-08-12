module Archimate
  class Document
    include Archimate::ErrorHelper

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
      "http://www.archimatetool.com/archimate".freeze => :archi,
      "http://www.opengroup.org/xsd/archimate".freeze => :archimate
    }.freeze

    def initialize(filename)
      @filename = filename
      @doc = nil
      @file_type = nil
    end

    def self.read(filename)
      document = new(filename)
      document.read
      document
    end

    def xpath_for(sym)
      XPATHS[@file_type][sym]
    end

    def element_type_names
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
      if (@file_type) == :archi
        el_type = el_type.gsub("archimate:", "")
      end
      el_type
    end

    # TODO: Add things like containing Folder, description of children, etc.
    def stringize(node)
      "#{element_type(node)} #{element_identifier(node)} #{node.elements.size} children"
    end

    def layer(node)
      return nil if node.nil? || node.document?
      # TODO: test for Archi format and archimate open exchange format
      if node.name == "folder" && !node["type"].nil?
        node["type"]
      else
        layer(node.parent)
      end
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

    # opens an output file, passing the io to the given block
    # if the file exists, and the overwrite answer is yes, then the file
    # is overwritten and the block is called
    # if the overwrite answer is no, then the method returns without calling
    # the block
    # $stdout is used if output is nil or empty
    def self.output_io(options, &block)
      output = options["output"]
      if output.nil? || output.empty?
        block.call($stdout)
      else
        if !options.key?("force") && File.exist?(output)
          return unless HighLine.new.agree("File #{output} exists. Overwrite?")
        end
        File.open(output, "w") do |f|
          block.call(f)
        end
      end
    end
  end
end
