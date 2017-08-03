# frozen_string_literal: true
require "nokogiri"

module Archimate
  module FileFormats
    class ModelExchangeFileWriter < Writer
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

      def serialize_label(xml, str)
        return if str.nil? || str.strip.empty?
        name_attrs = str.lang && !str.lang.empty? ? {"xml:lang" => str.lang} : {}
        xml.label(name_attrs) { xml.text text_proc(str) }
      end

      def serialize_relationships(xml)
        return if model.relationships.empty?
        xml.relationships { serialize(xml, model.relationships) }
      end

      def relationship_attributes(relationship)
        {
          identifier: identifier(relationship.id),
          source: identifier(relationship.source.id),
          target: identifier(relationship.target.id),
          "xsi:type" => meff_type(relationship.type)
        }
      end

      def serialize_relationship(xml, relationship)
        xml.relationship(
          relationship_attributes(relationship)
        ) do
          elementbase(xml, relationship)
        end
      end

      def serialize_organization_root(xml, organizations)
        return unless organizations && organizations.size > 0
        xml.organization do
          serialize(xml, organizations)
        end
      end

      def serialize_organization(xml, organization)
        if organization.items.empty? &&
          (!organization.documentation || organization.documentation.empty?) &&
          organization.organizations.empty?
          return
        end
        item_attrs = organization.id.nil? || organization.id.empty? ? {} : {identifier: organization.id}
        xml.item(item_attrs) do
          serialize_organization_body(xml, organization)
        end
      end

      def serialize_organization_body(xml, organization)
        if organization.items.empty? &&
          (!organization.documentation || organization.documentation.empty?) &&
          organization.organizations.empty?
          return
        end
        str = organization.name
        label_attrs = organization.name&.lang && !organization.name.lang.empty? ? {"xml:lang" => organization.name.lang} : {}
        xml.label(label_attrs) { xml.text text_proc(str) } unless str.nil? || str.strip.empty?
        serialize(xml, organization.documentation)
        serialize(xml, organization.organizations)
        organization.items.each { |i| serialize_item(xml, i) }
      end

      def serialize_properties(xml, element)
        return if element.properties.empty?
        xml.properties do
          serialize(xml, element.properties)
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
            style: font_style_string(style.font)
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

      def serialize_location(xml, location)
        xml.bendpoint(x: location.x.round, y: location.y.round)
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
