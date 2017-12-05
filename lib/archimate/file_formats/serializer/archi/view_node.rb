# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module Archi
        module ViewNode
          def serialize_view_node(xml, view_node)
            style_hash = archi_style_hash(view_node.style)
            fill_color = style_hash.delete("fillColor")
            xml.child(
              {
                "xsi:type" => view_node.type,
                "id" => view_node.id,
                "name" => view_node.name
              }.merge(
                style_hash.merge(
                  "targetConnections" => view_node.target_connections.empty? ? nil : view_node.target_connections.join(" "),
                  "fillColor" => fill_color,
                  "model" => view_node.view_refs&.id,
                  "archimateElement" => view_node.element&.id,
                  "type" => view_node.child_type
                )
              ).compact
            ) do
              serialize_bounds(xml, view_node.bounds)
              serialize(xml, (view_node.connections + view_node.diagram.connections.select { |conn| conn.source.id == view_node.id }).uniq)
              xml.content { xml.text view_node.content } if view_node.content
              serialize(xml, view_node.nodes)
              serialize_documentation(xml, view_node.documentation)
              serialize(xml, view_node.properties)
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
