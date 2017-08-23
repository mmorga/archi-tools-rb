# frozen_string_literal: true

module Archimate
  module FileFormats
    module Archi
      class ViewNode < FileFormats::SaxHandler
        def initialize(attrs, parent_handler)
          super
          @documentation = nil
          @properties = []
          @view_nodes = []
          @connections = []
          @characters = []
          @bounds = nil
          @style = nil
        end

        def complete
          style = DataModel::Style.new(
            text_alignment: @attrs["textAlignment"],
            fill_color: DataModel::Color.rgba(attrs["fillColor"]),
            line_color: DataModel::Color.rgba(attrs["lineColor"]),
            font_color: DataModel::Color.rgba(attrs["fontColor"]),
            font: DataModel::Font.archi_font_string(attrs["font"]),
            line_width: attrs["lineWidth"],
            text_position: attrs["textPosition"]
          )
          content = @characters.join("").strip
          content = nil if content.empty?
          view_node = DataModel::ViewNode.new(
            id: @attrs["id"],
            type: @attrs["xsi:type"],
            view_refs: nil,
            name: DataModel::LangString.string(@attrs["name"]),
            element: nil,
            bounds: @bounds,
            nodes: @view_nodes,
            connections: @connections,
            documentation: @documentation,
            properties: @properties,
            style: style,
            content: content,
            child_type: @attrs["type"],
            diagram: diagram
          )
          [
            event(:on_future, FutureReference.new(view_node, :view_refs, @attrs["model"])),
            event(:on_future, FutureReference.new(view_node, :element, @attrs["archimateElement"])),
            event(:on_referenceable, view_node),
            event(:on_view_node, view_node)
          ]
        end

        def on_documentation(documentation, source)
          @documentation = documentation
          false
        end

        def on_property(property, source)
          @properties << property
          false
        end

        def on_view_node(view_node, source)
          @view_nodes << view_node if source.parent_handler == self
          view_node
        end

        def on_connection(connection, source)
          @connections << connection if source.parent_handler == self
          connection
        end

        def on_bounds(bounds, source)
          @bounds = bounds
          false
        end

        def parse_viewpoint_type(viewpoint_idx)
          return nil unless viewpoint_idx
          viewpoint_idx = viewpoint_idx.to_i
          return nil if viewpoint_idx.nil?
          ArchiFileFormat::VIEWPOINTS[viewpoint_idx]
        end
      end
    end
  end
end
