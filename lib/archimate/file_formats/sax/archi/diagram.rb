# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module Archi
        class Diagram < FileFormats::Sax::Handler
          include Sax::CaptureDocumentation
          include Sax::CaptureProperties

          def initialize(name, attrs, parent_handler)
            super
            @view_nodes = []
            @connections = []
            @diagram = nil
          end

          def complete
            diagram.documentation = documentation
            diagram.properties = properties
            diagram.nodes = @view_nodes
            diagram.connections = @connections
            [
              event(:on_diagram, diagram),
              event(:on_referenceable, diagram)
            ]
          end

          def diagram
            @diagram ||= DataModel::Diagram.new(
              id: @attrs["id"],
              name: DataModel::LangString.string(process_text(@attrs["name"])),
              viewpoint_type: parse_viewpoint_type(@attrs["viewpoint"]),
              viewpoint: nil,
              connection_router_type: @attrs["connectionRouterType"],
              type: @attrs["xsi:type"],
              background: @attrs["background"]
            )
          end

          def on_view_node(view_node, source)
            @view_nodes << view_node if source.parent_handler == self
            false
          end

          def on_connection(connection, _source)
            @connections << connection
            false
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
