# frozen_string_literal: true
module Archimate
  module Diff
    class Relation
      attr_reader :id, :name, :type, :parent_xpath, :documentation, :properties, :source, :target

      def initialize(node)
        @id = node["id"]
        @name = node["name"]
        @type = node.attr("xsi:type")
        @source = node.attr("source")
        @target = node.attr("target")
        @parent_xpath = ELEMENT_TYPE_TO_PARENT_XPATH[@type]
        @documentation = Documentation.new(node)
        @properties = Properties.new(node)
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
end
