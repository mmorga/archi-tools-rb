# frozen_string_literal: true
require "nokogiri"

module Archimate
  module FileFormats
    class ModelExchangeFileWriter < Writer
      attr_reader :model

      def initialize(model)
        super
        @version = "2.1"
      end

      def write(output_io)
        builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          serialize_model(xml)
        end
        output_io.write(process_text(builder.to_xml))
      end

      def process_text(str)
        str
      end

      def serialize_model(xml)
        xml.model(
          "xmlns" => "http://www.opengroup.org/xsd/archimate",
          "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
          "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
          "xsi:schemaLocation" => "http://www.opengroup.org/xsd/archimate " \
            "http://www.opengroup.org/xsd/archimate/archimate_v2p1.xsd " \
            "http://purl.org/dc/elements/1.1/ " \
            "http://dublincore.org/schemas/xmls/qdc/2008/02/11/dc.xsd",
          "identifier" => "id-#{model.id}"
        ) do
          serialize_metadata(xml)
          xml.name("xml:lang" => "en") { xml.text model.name }
          serialize(xml, model.documentation)
          serialize_properties(xml, model)
          serialize_elements(xml)
          serialize_relationships(xml)
          serialize_organization(xml, model.folders)
          serialize_property_defs(xml)
          serialize_views(xml)
        end
      end

      def serialize_metadata(xml)
        xml.metadata do
          xml.schema { xml.text "Dublin Core" }
          xml.schemaversion { xml.text "1.1" }
          xml["dc"].title { xml.text "Archisurance Test Exchange Model" }
          xml["dc"].subject { xml.text "ArchiMate, Testing" }
          xml["dc"].description { xml.text "Test the Archisurance Exchange Model" }
          xml["dc"].language { xml.text "en" }
          xml["dc"].date { xml.text "2015-01-21 17:50" }
          xml["dc"].creator { xml.text "Phil Beauvoir" }
        end
      end

      def serialize_property_defs(xml)
        xml.propertydefs do
          keys = model.property_keys
          keys << "JunctionType"
          keys.sort.each do |key|
            xml.propertydef(
              "identifier" => key == "JunctionType" ? "propid-junctionType" : model.property_def_id(key),
              "name" => key,
              "type" => "string"
            )
          end
        end
      end

      def serialize_documentation(xml, documentation, element_name = "documentation")
        xml.send(element_name, "xml:lang" => documentation.lang) { xml.text(text_proc(documentation.text)) }
      end

      def serialize_elements(xml)
        xml.elements { serialize(xml, model.elements) } unless model.elements.empty?
      end

      def serialize_element(xml, element)
        return if element.type == "SketchModel" # TODO: print a warning that data is lost
        xml.element(identifier: "id-#{element['id']}",
                    "xsi:type" => meff_type(element.type)) do
          elementbase(xml, element)
        end
      end

      def elementbase(xml, element)
        serialize_label(xml, element.name)
        serialize(xml, element.documentation)
        serialize_properties(xml, element)
      end

      def serialize_label(xml, str)
        xml.label("xml:lang" => "en") { xml.text text_proc(str) } unless str.nil? || str.strip.empty?
      end

      def serialize_relationships(xml)
        xml.relationships { serialize(xml, model.relationships) } unless model.relationships.empty?
      end

      def serialize_relationship(xml, relationship)
        xml.relationship(
          identifier: "id-#{relationship.id}",
          source: "id-#{relationship.source}",
          target: "id-#{relationship.target}",
          "xsi:type" => meff_type(relationship.type)
        ) do
          elementbase(xml, relationship)
        end
      end

      def serialize_organization(xml, folders)
        xml.organization do
          serialize(xml, folders)
        end
      end

      def serialize_folder(xml, folder)
        return if folder.items.empty? && folder.documentation.empty? && folder.properties.empty? && folder.folders.empty?
        xml.item do
          serialize_label(xml, folder.name)
          serialize(xml, folder.documentation)
          serialize(xml, folder.folders)
          folder.items.each { |i| serialize_item(xml, i) }
        end
      end

      def serialize_item(xml, item)
        xml.item(identifierref: "id-#{item}")
      end

      def serialize_properties(xml, element)
        return if element.properties.empty?
        xml.properties do
          serialize(xml, element.properties)
        end
      end

      def serialize_property(xml, property)
        xml.property(identifierref: property.property_id) do
          xml.value("xml:lang" => property.lang) do
            xml.text text_proc(property.value) unless property.value.nil? || property.value.strip.empty?
          end
        end
      end

      def serialize_views(xml)
        xml.views do
          serialize(xml, model.diagrams)
        end
      end

      def serialize_diagram(xml, diagram)
        xml.view(
          remove_nil_values(
            identifier: "id-#{diagram.id}",
            viewpoint: diagram.viewpoint
          )
        ) do
          elementbase(xml, diagram)
          serialize(xml, diagram.children)
          serialize(xml, diagram.source_connections)
        end
      end

      def serialize_child(xml, child, x_offset = 0, y_offset = 0)
        child_attrs = {
          identifier: "id-#{child.id}",
          elementref: nil,
          x: child.bounds ? (child.bounds&.x + x_offset).round : nil,
          y: child.bounds ? (child.bounds&.y + y_offset).round : nil,
          w: child.bounds&.width&.round,
          h: child.bounds&.height&.round,
          type: nil
        }
        if child.archimate_element
          child_attrs[:elementref] = "id-#{child.archimate_element}"
        elsif child.model
          # Since it doesn't seem to be forbidden, we just assume we can use
          # the elementref for views in views
          child_attrs[:elementref] = child.model
          child_attrs[:type] = "model"
        else
          child_attrs[:type] = "group"
        end
        xml.node(remove_nil_values(child_attrs)) do
          serialize_label(xml, child.name) if child_attrs[:type] == "group"
          serialize(xml, child.style) if child.style
          child.children.each do |c|
            serialize_child(xml, c) #, child_attrs[:x].to_f, child_attrs[:y].to_f)
          end
        end
      end

      def serialize_style(xml, style)
        return unless style
        xml.style(
          remove_nil_values(
            lineWidth: style.line_width
          )
        ) do
          serialize_color(xml, style.fill_color, :fillColor)
          serialize_color(xml, style.line_color, :lineColor)
          serialize_font(xml, style)
          # TODO: complete this
        end
      end

      def serialize_font(xml, style)
        return unless style && (style.font || style.font_color)
        xml.font(
          remove_nil_values(
            name: style.font&.name,
            size: style.font&.size&.round,
            style: style.font&.style_string
          )
        ) { serialize_color(xml, style&.font_color, :color) }
      end

      def serialize_color(xml, color, sym)
        return if color.nil?
        h = {
          r: color.r,
          g: color.g,
          b: color.b,
          a: color.a
        }
        h.delete(:a) if color.a.nil? || color.a == 100
        xml.send(sym, h)
      end

      def serialize_source_connection(xml, sc)
        xml.connection(
          identifier: "id-#{sc.id}",
          relationshipref: "id-#{sc.relationship}",
          source: "id-#{sc.source}",
          target: "id-#{sc.target}"
        ) do
          serialize(xml, sc.bendpoints)
          serialize(xml, sc.style)
        end
      end

      def serialize_bendpoint(xml, bendpoint)
        xml.bendpoint(x: bendpoint.start_x.round, y: bendpoint.start_y.round)
      end

      def meff_type(el_type)
        el_type = el_type.sub(/^/, "")
        case el_type
        when 'AndJunction', 'OrJunction'
          'Junction'
        else
          el_type
        end
      end

      # # Processes text for text elements
      def text_proc(str)
        str.strip.tr("\r", "\n")
      end
    end
  end
end
