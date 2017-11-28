# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module Archi
        module ViewNode
          def serialize_view_node(xml, child)
            style_hash = archi_style_hash(child.style)
            fill_color = style_hash.delete("fillColor")
            xml.child(
              {
                "xsi:type" => child.type,
                "id" => child.id,
                "name" => child.name
              }.merge(
                style_hash.merge(
                  "targetConnections" => child.target_connections.empty? ? nil : child.target_connections.join(" "),
                  "fillColor" => fill_color,
                  "model" => child.view_refs&.id,
                  "archimateElement" => child.element&.id,
                  "type" => child.child_type
                )
              ).compact
            ) do
              serialize_bounds(xml, child.bounds)
              serialize(xml, (child.connections + child.diagram.connections.select { |conn| conn.source.id == child.id }).uniq)
              xml.content { xml.text child.content } if child.content
              serialize(xml, child.nodes)
              serialize_documentation(xml, child.documentation)
              serialize(xml, child.properties)
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
        end
      end
    end
  end
end
