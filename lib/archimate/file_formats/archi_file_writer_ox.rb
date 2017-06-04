# frozen_string_literal: true
require "ox"

module Archimate
  module FileFormats
    class ArchiFileWriterOx < Writer
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
        ).gsub('&apos;', "'")
      end

      def write(archifile_io)
        builder = Ox::Builder.new do |xml|
          xml.instruct('xml', version: "1.0", encoding: "UTF-8")
          serialize_model(xml)
        end
        archifile_io.write(
          process_text(
            builder.to_s
          )
        )
      end

      def serialize_model(xml)
        xml.element(
          "archimate:model",
          "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
          "xmlns:archimate" => "http://www.archimatetool.com/archimate",
          "name" => model.name,
          "id" => model.id,
          "version" => @version
        ) do
          serialize(xml, model.folders)
          serialize(xml, model.properties)
          model.documentation.each { |d| serialize_documentation(xml, d, "purpose") }
        end
      end

      def serialize_folder(xml, folder)
        xml.element(
          "folder",
          remove_nil_values(name: folder.name, id: folder.id, type: folder.type)
        ) do
          serialize(xml, folder.folders)
          serialize(xml, folder.documentation)
          serialize(xml, folder.properties)
          folder.items.each { |i| serialize_item(xml, i) }
        end
      end

      def serialize_property(xml, property)
        xml.element("property", remove_nil_values(key: property.key, value: property.value))
        xml.pop
      end

      def serialize_documentation(xml, documentation, element_name = "documentation")
        xml.element(element_name) { xml.text(documentation.text) }
      end

      def serialize_item(xml, item)
        serialize(xml, model.lookup(item))
      end

      def serialize_element(xml, element)
        xml.element(
          "element",
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
          "element",
          remove_nil_values(
            "xsi:type" => "archimate:#{rel.type}",
            "id" => rel.id,
            "name" => rel.name,
            "source" => rel.source,
            "target" => rel.target,
            "accessType" => rel.access_type&.to_s
          )
        ) do
          serialize(xml, rel.documentation)
          serialize(xml, rel.properties)
        end
      end

      def serialize_diagram(xml, diagram)
        xml.element(
          "element",
          remove_nil_values(
            "xsi:type" => diagram.type || "archimate:ArchimateDiagramModel",
            "id" => diagram.id,
            "name" => diagram.name,
            "connectionRouterType" => diagram.connection_router_type&.to_s,
            "viewpoint" => ArchiFileFormat::VIEWPOINTS.index(diagram.viewpoint)&.to_s,
            "background" => diagram.background&.to_s
          )
        ) do
          serialize(xml, diagram.children)
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
          "textPosition" => style&.text_position&.to_s
        }
      end

      def serialize_child(xml, child)
        style_hash = archi_style_hash(child.style)
        fill_color = style_hash.delete("fillColor")
        xml.element(
          "child",
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
                "type" => child.child_type&.to_s
              )
            )
          )
        ) do
          serialize(xml, child.bounds) unless child.bounds.nil?
          serialize(xml, child.source_connections)
          xml.element("content") { xml.text child.content } unless child.content.nil?
          serialize(xml, child.children)
          serialize(xml, child.documentation)
          serialize(xml, child.properties)
        end
      end

      def serialize_bounds(xml, bounds)
        xml.element(
          "bounds",
          remove_nil_values(
            x: bounds.x&.to_i&.to_s,
            y: bounds.y&.to_i&.to_s,
            width: bounds.width&.to_i&.to_s,
            height: bounds.height&.to_i&.to_s
          )
        )
        xml.pop
      end

      def serialize_source_connection(xml, source_connection)
        xml.element(
          "sourceConnection",
          remove_nil_values(
            {
              "xsi:type" => source_connection.type,
              "id" => source_connection.id,
              "name" => source_connection.name
            }.merge(
              archi_style_hash(source_connection.style).merge(
                "source" => source_connection.source,
                "target" => source_connection.target,
                "relationship" => source_connection.relationship
              )
            )
          )
        ) do
          serialize(xml, source_connection.bendpoints)
          serialize(xml, source_connection.documentation)
          serialize(xml, source_connection.properties)
        end
      end

      def serialize_bendpoint(xml, bendpoint)
        xml.element(
          "bendpoint",
          remove_nil_values(
            startX: bendpoint.start_x&.to_i&.to_s,
            startY: bendpoint.start_y&.to_i&.to_s,
            endX: bendpoint.end_x&.to_i&.to_s,
            endY: bendpoint.end_y&.to_i&.to_s
          )
        )
        xml.pop
      end
    end
  end
end
