# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module Archi
        class ViewNode < FileFormats::Sax::Handler
          include Sax::CaptureDocumentation
          include Sax::CaptureProperties
          include Style

          def initialize(name, attrs, parent_handler)
            super
            @view_nodes = []
            @connections = []
            @bounds = nil
            @content = nil
            @view_node = nil
          end

          def complete
            [
              event(:on_future, Sax::FutureReference.new(view_node, :view_refs, attrs["model"])),
              event(:on_future, Sax::FutureReference.new(view_node, :element, attrs["archimateElement"])),
              event(:on_referenceable, view_node),
              event(:on_view_node, view_node)
            ]
          end

          def on_view_node(view_node, source)
            @view_nodes << view_node if source.parent_handler == self
            view_node
          end

          def on_connection(connection, source)
            @connections << connection if source.parent_handler == self
            connection
          end

          def on_content(string, _source)
            @content = string
          end

          def on_bounds(bounds, _source)
            @bounds = bounds
            false
          end

          private

          def view_node
            @view_node ||= DataModel::ViewNode.new(
              id: attrs["id"],
              type: attrs["xsi:type"],
              view_refs: nil,
              name: DataModel::LangString.string(process_text(attrs["name"])),
              element: nil,
              bounds: @bounds,
              nodes: @view_nodes,
              connections: @connections,
              documentation: documentation,
              properties: properties,
              style: style,
              content: @content,
              child_type: attrs["type"],
              diagram: diagram
            )
          end

          def parse_viewpoint_type(viewpoint_idx)
            return nil unless viewpoint_idx
            viewpoint_idx = viewpoint_idx.to_i
            return nil if viewpoint_idx.nil?
            ArchimateV2::VIEWPOINTS[viewpoint_idx]
          end
        end
      end
    end
  end
end
