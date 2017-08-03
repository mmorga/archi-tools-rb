# frozen_string_literal: true
require "nokogiri"

module Archimate
  module FileFormats
    class ModelExchangeFileWriter30 < ModelExchangeFileWriter
      def initialize(model)
        super
      end

      def model_attrs
        remove_nil_values(
          model_namespaces.merge(
            "xsi:schemaLocation" => model.schema_locations.join(" "),
            "identifier" => identifier(model.id),
            "version" => model.version
          )
        )
      end

      def serialize_model(xml)
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

      def serialize_label(xml, str, tag = :name)
        return if str.nil? || str.strip.empty?
        name_attrs = str.lang && !str.lang.empty? ? {"xml:lang" => str.lang} : {}
        xml.send(tag, name_attrs) { xml.text text_proc(str) }
      end

      def relationship_attributes(relationship)
        attrs = super
        attrs["accessType"] = relationship.access_type if relationship.access_type
        attrs
      end

      def serialize_organization_root(xml, organizations)
        return unless organizations && organizations.size > 0
        xml.organizations do
          serialize_organization_body(xml, organizations[0])
        end
      end

      def serialize_item(xml, item)
        xml.item(identifierRef: identifier(item.id))
      end

      def serialize_property(xml, property)
        xml.property("propertyDefinitionRef" => property.property_definition.id) do
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
            viewpoint: diagram.viewpoint_type
          )
        ) do
          elementbase(xml, diagram)
          serialize(xml, diagram.nodes)
          serialize(xml, diagram.connections)
        end
      end

      def view_node_attrs(view_node, x_offset = 0, y_offset = 0)
        attrs = {
          identifier: identifier(view_node.id),
          elementRef: nil,
          "xsi:type" => view_node.type,
          "x" => view_node.bounds ? (view_node.bounds&.x + x_offset).round : nil,
          "y" => view_node.bounds ? (view_node.bounds&.y + y_offset).round : nil,
          "w" => view_node.bounds&.width&.round,
          "h" => view_node.bounds&.height&.round
        }
        if view_node.element
          attrs[:elementRef] = identifier(view_node.element.id)
        elsif view_node.view_refs
          # Since it doesn't seem to be forbidden, we just assume we can use
          # the elementref for views in views
          attrs[:elementRef] = view_node.view_refs
          attrs[:type] = "model"
        end
        remove_nil_values(attrs)
      end

      def serialize_view_node(xml, view_node, x_offset = 0, y_offset = 0)
        attrs = view_node_attrs(view_node, x_offset, y_offset)
        xml.node(attrs) do
          serialize_label(xml, view_node.name, :label)
          serialize(xml, view_node.style) if view_node.style
          view_node.nodes.each do |c|
            serialize_view_node(xml, c) # , view_node_attrs[:x].to_f, view_node_attrs[:y].to_f)
          end
        end
      end

      def font_style_string(font)
        case font&.style
        when 1
          "italic"
        when 2
          "bold"
        when 3
          "bold italic"
        end
      end

      def serialize_connection(xml, sc)
        xml.connection(
          identifier: identifier(sc.id),
          relationshipRef: identifier(sc.relationship&.id),
          "xsi:type": sc.type,
          source: identifier(sc.source&.id),
          target: identifier(sc.target&.id)
        ) do
          serialize(xml, sc.style)
          serialize(xml, sc.bendpoints)
        end
      end

      def meff_type(el_type)
        el_type.sub(/^/, "")
      end
    end
  end
end
