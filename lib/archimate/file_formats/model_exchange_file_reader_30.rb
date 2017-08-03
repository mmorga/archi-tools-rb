# frozen_string_literal: true
require "nokogiri"

module Archimate
  module FileFormats
    class ModelExchangeFileReader30 < ModelExchangeFileReader
      def parse_archimate_version(root)
        case root.namespace.href
        when "http://www.opengroup.org/xsd/archimate/3.0/"
          :archimate_3_0
        else
          raise "Unexpected namespace version: #{root.namespace.href}"
        end
      end

      def organizations_root_selector
        ">organizations"
      end

      def property_defs_selector
          ">propertyDefinitions>propertyDefinition"
      end

      def property_def_attr_name
        "propertyDefinitionRef"
      end

      def property_def_name(node)
        ModelExchangeFile::XmlLangString.parse(node.at_css("name"))
      end

      def parse_element_name(el)
        ModelExchangeFile::XmlLangString.parse(el.at_css(">name"))
      end

      def identifier_ref_name
        "identifierRef"
      end

      def diagrams_path
        ">views>diagrams>view"
      end

      def view_node_element_ref
        "elementRef"
      end

      def view_node_type_attr
        "xsi:type"
      end

      def connection_relationship_ref
        "relationshipRef"
      end

      def style_to_int(str)
        case str
        when nil
          0
        when "italic"
          1
        when "bold"
          2
        when "bold italic"
          3
        else
          raise "Broken for value: #{str}"
        end
      end

      # <xs:simpleType name="ViewpointPurposeEnum">
      #     <xs:restriction base="xs:NMTOKEN">
      #         <xs:enumeration value="Designing" />
      #         <xs:enumeration value="Deciding" />
      #         <xs:enumeration value="Informing" />
      #     </xs:restriction>
      # </xs:simpleType>

      # <xs:simpleType name="ViewpointPurposeType">
      #     <xs:list itemType="ViewpointPurposeEnum" />
      # </xs:simpleType>

      # <xs:simpleType name="ViewpointContentEnum">
      #     <xs:restriction base="xs:NMTOKEN">
      #         <xs:enumeration value="Details" />
      #         <xs:enumeration value="Coherence" />
      #         <xs:enumeration value="Overview" />
      #     </xs:restriction>
      # </xs:simpleType>

      # <xs:simpleType name="ViewpointContentType">
      #     <xs:list itemType="ViewpointContentEnum" />
      # </xs:simpleType>

      # <xs:complexType name="ViewpointType">
      #     <xs:complexContent>
      #         <xs:extension base="NamedReferenceableType">
      #             <xs:sequence>
      #                 <xs:group ref="PropertiesGroup" />
      #                 <xs:element name="concern" type="ConcernType" minOccurs="0" maxOccurs="unbounded" />
      #                 <xs:element name="viewpointPurpose" type="ViewpointPurposeType" minOccurs="0" maxOccurs="1" />
      #                 <xs:element name="viewpointContent" type="ViewpointContentType" minOccurs="0" maxOccurs="1" />
      #                 <xs:element name="allowedElementType" type="AllowedElementTypeType" minOccurs="0" maxOccurs="unbounded" />
      #                 <xs:element name="allowedRelationshipType" type="AllowedRelationshipTypeType" minOccurs="0" maxOccurs="unbounded" />
      #                 <xs:element name="modelingNote" type="ModelingNoteType" minOccurs="0" maxOccurs="unbounded" />
      #             </xs:sequence>
      #         </xs:extension>
      #     </xs:complexContent>
      # </xs:complexType>
      def parse_viewpoints(model)
        []
        # model.css("views > viewpoints").map do |i|
          # attribute :concern, Strict::Array.member(Concern).default([])
          # attribute :viewpointPurpose, Strict::Array.member(ViewpointPurposeEnum).default([])
          # attribute :viewpointContent, Strict::Array.member(ViewpointContentEnum).default([])
          # attribute :allowedElementTypes, Strict::Array.member(ElementType).default([])
          # attribute :allowedRelationshipTypes, Strict::Array.member(RelationshipType).default([])
          # attribute :modelingNotes, Strict::Array.member(ModelingNote).default([])
          # DataModel::Viewpoint.new(
            #     id: identifier_to_id(i["identifier"]),
            #     name: parse_element_name(i),
            #     documentation: parse_documentation(i),
            #     properties: parse_properties(i),
            #     nodes: nodes,
            #     connections: connections,
            #     connection_router_type: i["connectionRouterType"],
            #     type: i.attr("xsi:type"),
            #     background: i.attr("background")
          # )
        # end
      end
    end
  end
end
