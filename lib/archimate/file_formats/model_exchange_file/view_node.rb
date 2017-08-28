# frozen_string_literal: true

module Archimate
  module FileFormats
    module ModelExchangeFile
      class ViewNode < FileFormats::Sax::Handler
        include Sax::CaptureDocumentation
        include Sax::CaptureProperties

        def initialize(name, attrs, parent_handler)
          super
          @view_nodes = []
          @connections = []
          @content = nil
          @view_node_name = nil
          @style = nil
        end

        def complete
          bounds = DataModel::Bounds.new(x: @attrs["x"], y: @attrs["y"], width: @attrs["w"], height: @attrs["h"])
          view_node = DataModel::ViewNode.new(
            id: @attrs["identifier"],
            type: @attrs["type"],
            view_refs: nil,
            name: @view_node_name,
            element: nil,
            bounds: bounds,
            nodes: @view_nodes,
            connections: @connections,
            documentation: documentation,
            properties: properties,
            style: @style,
            content: @content,
            child_type: @attrs["type"],
            diagram: diagram
          )
          [
            event(:on_future, Sax::FutureReference.new(view_node, :view_refs, @attrs["model"])),
            event(:on_future, Sax::FutureReference.new(view_node, :element, @attrs["elementref"])),
            event(:on_referenceable, view_node),
            event(:on_view_node, view_node)
          ]
        end

        def on_lang_string(name, source)
          @view_node_name = name
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

        def on_content(string, source)
          @content = string
        end

        def on_style(style, source)
          @style = style
          false
        end
      end
    end
  end
end
