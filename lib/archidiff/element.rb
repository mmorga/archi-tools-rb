module Archidiff
  class Element
    attr_reader :id, :name, :type, :parent_xpath, :documentation, :properties

    def initialize(node)
      @id = node["id"]
      @name = node["name"]
      @type = node.attr("xsi:type")
      @parent_xpath = ELEMENT_TYPE_TO_PARENT_XPATH[@type]
      @documentation = DocumentationList.new(node.css(">documentation"))
      @properties = PropertyList.new(node.css(">property"))
    end

    def ==(other)
      @id == other.id &&
        @name == other.name &&
        @type == other.type &&
        @documentation == other.documentation &&
        @properties == other.properties
    end
  end
end
