# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module ModelExchangeFile
        module V21
          module ViewNode
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

            def view_node_attrs(view_node, x_offset = 0, y_offset = 0)
              attrs = {
                identifier: identifier(view_node.id),
                elementref: nil,
                x: view_node.bounds ? (view_node.bounds&.x + x_offset).round : nil,
                y: view_node.bounds ? (view_node.bounds&.y + y_offset).round : nil,
                w: view_node.bounds&.width&.round,
                h: view_node.bounds&.height&.round,
                type: view_node.child_type
              }
              if view_node.element
                attrs[:elementref] = identifier(view_node.element.id)
              elsif view_node.view_refs
                # Since it doesn't seem to be forbidden, we just assume we can use
                # the elementref for views in views
                attrs[:elementref] = view_node.view_refs
              end
              attrs.compact
            end
          end
        end
      end
    end
  end
end
