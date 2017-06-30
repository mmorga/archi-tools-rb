# frozen_string_literal: true
require "nokogiri"

module Archimate
  module FileFormats
    # This class implements a file reader for ArchiMate 2.1 Model Exchange Format
    class ModelExchangeFileReader21 < ModelExchangeFileReader
      def parse_archimate_version(root)
        case root.namespace.href
        when "http://www.opengroup.org/xsd/archimate"
          :archimate_2_1
        else
          raise "Unexpected namespace: #{root.namespace.href}"
        end
      end

      def organizations_root_selector
        ">organization>item"
      end

      def property_defs_selector
        ">propertydefs>propertydef"
      end

      def property_def_attr_name
        "identifierref"
      end

      def property_def_name(node)
        node["name"]
      end

      def parse_element_name(el)
        ModelExchangeFile::XmlLangString.parse(el.at_css(">label"))
      end

      def identifier_ref_name
        "identifierref"
      end

      def diagrams_path
        ">views>view"
      end

      def view_node_element_ref
        "elementref"
      end

      def view_node_type_attr
        "type"
      end

      def connection_relationship_ref
        "relationshipref"
      end

      def style_to_int(str)
        case str
        when nil
          0
        when "italic"
          1
        when "bold"
          2
        when "bold|italic"
          3
        else
          raise "Broken for value: #{str}"
        end
      end
    end
  end
end
