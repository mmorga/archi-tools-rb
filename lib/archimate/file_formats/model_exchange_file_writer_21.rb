# frozen_string_literal: true
require "nokogiri"

module Archimate
  module FileFormats
    # Archimate version 2.1 Model Exchange Format Writer
    class ModelExchangeFileWriter21 < ModelExchangeFileWriter
      def initialize(model)
        super
      end

      def model_attrs
        model_namespaces.merge(
          "xsi:schemaLocation" => model.schema_locations.join(" "),
          "identifier" => identifier(model.id)
        )
      end

      def serialize_model(xml)
        xml.model(model_attrs) do
          ModelExchangeFile::XmlMetadata.new(model.metadata).serialize(xml)
          ModelExchangeFile::XmlLangString.new(model.name, :name).serialize(xml)
          ModelExchangeFile::XmlLangString.new(model.documentation, :documentation).serialize(xml)
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
        ModelExchangeFile::XmlPropertyDefs.new(model.property_definitions).serialize(xml)
      end

      def serialize_label(xml, str)
        return if str.nil? || str.strip.empty?
        name_attrs = str.lang && !str.lang.empty? ? {"xml:lang" => str.lang} : {}
        xml.label(name_attrs) { xml.text text_proc(str) }
      end

      def serialize_organization_root(xml, organizations)
        return unless organizations && organizations.size > 0
        xml.organization do
          serialize(xml, organizations)
        end
      end

      def serialize_item(xml, item)
        xml.item(identifierref: identifier(item))
      end

      def serialize_property(xml, property)
        xml.property(identifierref: property.property_definition.id) do
          ModelExchangeFile::XmlLangString.new(property.value, :value).serialize(xml)
        end
      end

      def serialize_views(xml)
        return if model.diagrams.empty?
        xml.views do
          serialize(xml, model.diagrams)
        end
      end

      def serialize_diagram(xml, diagram)
        xml.view(
          remove_nil_values(
            identifier: identifier(diagram.id),
            viewpoint: diagram.viewpoint,
            "xsi:type": diagram.type
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
          elementref: nil,
          x: view_node.bounds ? (view_node.bounds&.x + x_offset).round : nil,
          y: view_node.bounds ? (view_node.bounds&.y + y_offset).round : nil,
          w: view_node.bounds&.width&.round,
          h: view_node.bounds&.height&.round,
          type: nil
        }
        if view_node.archimate_element
          attrs[:elementref] = identifier(view_node.archimate_element)
        elsif view_node.model
          # Since it doesn't seem to be forbidden, we just assume we can use
          # the elementref for views in views
          attrs[:elementref] = view_node.model
          attrs[:type] = "model"
        else
          attrs[:type] = "group"
        end
        remove_nil_values(attrs)
      end

      def serialize_view_node(xml, view_node, x_offset = 0, y_offset = 0)
        attrs = view_node_attrs(view_node, x_offset, y_offset)
        xml.node(attrs) do
          serialize_label(xml, view_node.name) if attrs[:type] == "group"
          serialize(xml, view_node.style) if view_node.style
          view_node.nodes.each do |c|
            serialize_view_node(xml, c) # , attrs[:x].to_f, attrs[:y].to_f)
          end
        end
      end

      def font_style_string(font)
        font&.style_string
      end

      def serialize_connection(xml, sc)
        xml.connection(
          identifier: identifier(sc.id),
          relationshipref: identifier(sc.relationship),
          source: identifier(sc.source),
          target: identifier(sc.target)
        ) do
          serialize(xml, sc.bendpoints)
          serialize(xml, sc.style)
        end
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
    end
  end
end
