# frozen_string_literal: true
require "nokogiri"

module Archimate
  module FileFormats
    class ArchiFileWriter < Writer
      using DataModel::DiffableArray
      using DataModel::DiffablePrimitive

      TEXT_SUBSTITUTIONS = [
        ['&#13;', '&#xD;'],
        ['"', '&quot;'],
        ['&gt;', '>']
      ].freeze

      def initialize(model)
        super
        @version = "3.1.1"
      end

      def process_text(doc_str)
        %w(documentation content).each do |tag|
          TEXT_SUBSTITUTIONS.each do |from, to|
            doc_str.gsub!(%r{<#{tag}>([^<]*#{from}[^<]*)</#{tag}>}) do |str|
              str.gsub(from, to)
            end
          end
        end
        doc_str.gsub(
          %r{<(/)?archimate:}, "<\\1"
        ).gsub(
          %r{<(/)?model}, "<\\1archimate:model"
        )
      end

      def write(archifile_io)
        builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          serialize_model(xml)
        end
        archifile_io.write(
          process_text(
            builder.to_xml
          )
        )
      end

      def serialize_model(xml)
        xml["archimate"].model(
          "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
          "xmlns:archimate" => "http://www.archimatetool.com/archimate",
          "name" => model.name,
          "id" => model.id,
          "version" => @version
        ) do
          serialize(xml, model.organizations)
          serialize(xml, model.properties)
          model.documentation.each { |d| serialize_documentation(xml, d, "purpose") }
        end
      end

      def serialize_organization(xml, organization)
        xml.folder(
          remove_nil_values(name: organization.name, id: organization.id, type: organization.type)
        ) do
          serialize(xml, organization.organizations)
          serialize(xml, organization.documentation)
          organization.items.each { |i| serialize_item(xml, i) }
        end
      end

      def serialize_property(xml, property)
        xml.property(remove_nil_values(key: property.key, value: property.value))
      end

      def serialize_documentation(xml, documentation, element_name = "documentation")
        xml.send(element_name) { xml.text(documentation.text) }
      end

      def serialize_item(xml, item)
        item_instance = model.lookup(item)
        $stderr.puts "serialize_item item `#{item.inspect}` could not found." if item_instance.nil?
        serialize(xml, item_instance)
      end

      def serialize_element(xml, element)
        xml.element(
          remove_nil_values(
            "xsi:type" => "archimate:#{element.type}",
            "id" => element.id,
            "name" => element.name
          )
        ) do
          serialize(xml, element.documentation)
          serialize(xml, element.properties)
        end
      end

      def serialize_relationship(xml, rel)
        xml.element(
          remove_nil_values(
            "xsi:type" => "archimate:#{rel.type}",
            "id" => rel.id,
            "name" => rel.name,
            "source" => rel.source,
            "target" => rel.target,
            "accessType" => serialize_access_type(rel.access_type)
          )
        ) do
          serialize(xml, rel.documentation)
          serialize(xml, rel.properties)
        end
      end

      def serialize_access_type(val)
        case val
        when nil
          nil
        else
          DataModel::AccessType.index(val)
        end
      end

      def serialize_diagram(xml, diagram)
        xml.element(
          remove_nil_values(
            "xsi:type" => diagram.type || "archimate:ArchimateDiagramModel",
            "id" => diagram.id,
            "name" => diagram.name,
            "connectionRouterType" => diagram.connection_router_type,
            "viewpoint" => ArchiFileFormat::VIEWPOINTS.index(diagram.viewpoint_type)&.to_s,
            "background" => diagram.background
          )
        ) do
          serialize(xml, diagram.nodes)
          serialize(xml, diagram.documentation)
          serialize(xml, diagram.properties)
        end
      end

      def archi_style_hash(style)
        {
          "fillColor" => style&.fill_color&.to_rgba,
          "font" => style&.font&.to_archi_font,
          "fontColor" => style&.font_color&.to_rgba,
          "lineColor" => style&.line_color&.to_rgba,
          "lineWidth" => style&.line_width&.to_s,
          "textAlignment" => style&.text_alignment&.to_s,
          "textPosition" => style&.text_position
        }
      end

      def serialize_view_node(xml, child)
        style_hash = archi_style_hash(child.style)
        fill_color = style_hash.delete("fillColor")
        xml.child(
          remove_nil_values(
            {
              "xsi:type" => child.type,
              "id" => child.id,
              "name" => child.name
            }.merge(
              style_hash.merge(
                "targetConnections" => child.target_connections.empty? ? nil : child.target_connections.join(" "),
                "fillColor" => fill_color,
                "model" => child.model,
                "archimateElement" => child.archimate_element,
                "type" => child.child_type
              )
            )
          )
        ) do
          serialize(xml, child.bounds) unless child.bounds.nil?
          serialize(xml, child.connections)
          xml.content { xml.text child.content } unless child.content.nil?
          serialize(xml, child.nodes)
          serialize(xml, child.documentation)
          serialize(xml, child.properties)
        end
      end

      def serialize_bounds(xml, bounds)
        xml.bounds(
          remove_nil_values(
            x: bounds.x&.to_i,
            y: bounds.y&.to_i,
            width: bounds.width&.to_i,
            height: bounds.height&.to_i
          )
        )
      end

      def serialize_connection(xml, connection)
        xml.sourceConnection(
          remove_nil_values(
            {
              "xsi:type" => connection.type,
              "id" => connection.id,
              "name" => connection.name
            }.merge(
              archi_style_hash(connection.style).merge(
                "source" => connection.source,
                "target" => connection.target,
                "relationship" => connection.relationship
              )
            )
          )
        ) do
          serialize(xml, connection.bendpoints)
          serialize(xml, connection.documentation)
          serialize(xml, connection.properties)
        end
      end

      # startX = location.x - source_attachment.x
      # startY = location.y - source_attachment.y
      # endX = location.x - target_attachment.x
      # endY = location.y - source_attachment.y
      def serialize_location(xml, bendpoint)
        xml.bendpoint(
          remove_nil_values(
            startX: bendpoint.x == 0 ? nil : bendpoint.x&.to_i,
            startY: bendpoint.y == 0 ? nil : bendpoint.y&.to_i,
            endX: bendpoint.end_x&.to_i,
            endY: bendpoint.end_y&.to_i
          )
        )
      end
    end
  end
end
