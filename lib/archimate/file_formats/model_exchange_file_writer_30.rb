# frozen_string_literal: true
require "nokogiri"
require 'archimate/file_formats/model_exchange_file/xml_lang_string'
require 'archimate/file_formats/model_exchange_file/xml_metadata'
require 'archimate/file_formats/model_exchange_file/xml_property_definitions'
require 'archimate/file_formats/model_exchange_file/xml_property_defs'

module Archimate
  module FileFormats
    class ModelExchangeFileWriter30 < Writer
      attr_reader :model

      def initialize(model)
        super
      end

      def write(output_io)
        builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          serialize_model(xml)
        end
        output_io.write(builder.to_xml)
      end

      def serialize_model(xml)
        model_attrs = remove_nil_values(
          model_namespaces.merge(
            "xsi:schemaLocation" => model.schema_locations.join(" "),
            "identifier" => identifier(model.id),
            "version" => model.version
          )
        )
        xml.model(model_attrs) do
          ModelExchangeFile::XmlLangString.new(model.name, :name).serialize(xml)
          ModelExchangeFile::XmlLangString.new(model.documentation, :documentation).serialize(xml)
          ModelExchangeFile::XmlMetadata.new(model.metadata).serialize(xml)
          serialize_properties(xml, model)
          serialize_elements(xml)
          serialize_relationships(xml)
          serialize_organization_root(xml, model.organizations)
          serialize_property_defs(xml)
          serialize_views(xml)
        end
      end

      def serialize_property_defs(xml)
        return if model.property_definitions.empty?
        ModelExchangeFile::XmlPropertyDefinitions.new(model.property_definitions).serialize(xml)
      end

      def serialize_elements(xml)
        xml.elements { serialize(xml, model.elements) } unless model.elements.empty?
      end

      def serialize_element(xml, element)
        return if element.type == "SketchModel" # TODO: print a warning that data is lost
        xml.element(identifier: identifier(element['id']),
                    "xsi:type" => meff_type(element.type)) do
          elementbase(xml, element)
        end
      end

      def elementbase(xml, element)
        serialize_label(xml, element.name)
        serialize(xml, element.documentation)
        serialize_properties(xml, element)
      end

      def serialize_label(xml, str, tag = :name)
        return if str.nil? || str.strip.empty?
        name_attrs = str.lang && !str.lang.empty? ? {"xml:lang" => str.lang} : {}
        xml.send(tag, name_attrs) { xml.text text_proc(str) }
      end

      def serialize_relationships(xml)
        xml.relationships { serialize(xml, model.relationships) } unless model.relationships.empty?
      end

      def serialize_relationship(xml, relationship)
        attrs = {
          identifier: identifier(relationship.id),
          source: identifier(relationship.source),
          target: identifier(relationship.target),
          "xsi:type" => meff_type(relationship.type)
        }
        attrs["accessType"] = relationship.access_type if relationship.access_type

        xml.relationship(attrs) do
          elementbase(xml, relationship)
        end
      end

      def serialize_organization_root(xml, organizations)
        return unless organizations && organizations.size > 0
        xml.organizations do
          serialize_organization_body(xml, organizations[0])
        end
      end

      def serialize_organization(xml, organization)
        return if organization.items.empty? && organization.documentation.empty? && organization.organizations.empty?
        item_attrs = organization.id.nil? || organization.id.empty? ? {} : {identifier: organization.id}
        xml.item(item_attrs) do
          serialize_organization_body(xml, organization)
        end
      end

      def serialize_organization_body(xml, organization)
        return if organization.items.empty? && organization.documentation.empty? && organization.organizations.empty?
        str = organization.name
        label_attrs = organization.name&.lang && !organization.name.lang.empty? ? {"xml:lang" => organization.name.lang} : {}
        xml.label(label_attrs) { xml.text text_proc(str) } unless str.nil? || str.strip.empty?
        serialize(xml, organization.documentation)
        serialize(xml, organization.organizations)
        organization.items.each { |i| serialize_item(xml, i) }
      end

      def serialize_item(xml, item)
        xml.item(identifierRef: identifier(item))
      end

      def serialize_properties(xml, element)
        return if element.properties.empty?
        xml.properties do
          serialize(xml, element.properties)
        end
      end

      def serialize_property(xml, property)
        xml.property("propertyDefinitionRef" => property.property_definition_id) do
          ModelExchangeFile::XmlLangString.new(property.value, :value).serialize(xml)
        end
      end

      def serialize_views(xml)
        return if model.diagrams.empty?
        xml.views do
          xml.diagrams {
            serialize(xml, model.diagrams)
          }
        end
      end

      def serialize_diagram(xml, diagram)
        xml.view(
          remove_nil_values(
            identifier: identifier(diagram.id),
            "xsi:type": diagram.type,
            viewpoint: diagram.viewpoint
          )
        ) do
          elementbase(xml, diagram)
          serialize(xml, diagram.nodes)
          serialize(xml, diagram.connections)
        end
      end

      def serialize_view_node(xml, view_node, x_offset = 0, y_offset = 0)
        view_node_attrs = {
          identifier: identifier(view_node.id),
          elementRef: nil,
          "xsi:type" => view_node.type,
          "x" => view_node.bounds ? (view_node.bounds&.x + x_offset).round : nil,
          "y" => view_node.bounds ? (view_node.bounds&.y + y_offset).round : nil,
          "w" => view_node.bounds&.width&.round,
          "h" => view_node.bounds&.height&.round
        }
        if view_node.archimate_element
          view_node_attrs[:elementRef] = identifier(view_node.archimate_element)
        elsif view_node.model
          # Since it doesn't seem to be forbidden, we just assume we can use
          # the elementref for views in views
          view_node_attrs[:elementRef] = view_node.model
          view_node_attrs[:type] = "model"
        end
        xml.node(remove_nil_values(view_node_attrs)) do
          serialize_label(xml, view_node.name, :label)
          serialize(xml, view_node.style) if view_node.style
          view_node.nodes.each do |c|
            serialize_view_node(xml, c) # , view_node_attrs[:x].to_f, view_node_attrs[:y].to_f)
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

      def style_string(style)
        case style
        when 1
          "italic"
        when 2
          "bold"
        when 3
          "bold italic"
        end
      end

      def serialize_font(xml, style)
        return unless style && (style.font || style.font_color)
        xml.font(
          remove_nil_values(
            name: style.font&.name,
            size: style.font&.size&.round,
            style: style_string(style.font&.style)
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

      def serialize_connection(xml, sc)
        xml.connection(
          identifier: identifier(sc.id),
          relationshipRef: identifier(sc.relationship),
          "xsi:type": sc.type,
          source: identifier(sc.source),
          target: identifier(sc.target)
        ) do
          serialize(xml, sc.style)
          serialize(xml, sc.bendpoints)
        end
      end

      def serialize_location(xml, location)
        xml.bendpoint(x: location.x.round, y: location.y.round)
      end

      def meff_type(el_type)
        el_type.sub(/^/, "")
      end

      # # Processes text for text elements
      def text_proc(str)
        str.strip.tr("\r", "\n")
      end

      # TODO: this should replace namespaces as appropriate for the desired export version
      def model_namespaces
        model.namespaces
      end

      # TODO: Archi uses hex numbers for ids which may not be valid for
      # identifer. If we are converting from Archi, decorate the IDs here.
      def identifier(str)
        return "id-#{str}" if str =~ /^\d/
        str
      end
    end
  end
end
