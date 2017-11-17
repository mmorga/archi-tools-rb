# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module ModelExchangeFile
        class Diagram < FileFormats::Sax::Handler
          include Sax::CaptureDocumentation
          include Sax::CaptureProperties

          def initialize(name, attrs, parent_handler)
            super
            @view_nodes = []
            @connections = []
            @diagram_name = nil
            @diagram = nil
          end

          def complete
            diagram.name = @diagram_name
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
              id: @attrs["identifier"],
              viewpoint_type: @attrs["viewpoint"],
              viewpoint: DataModel::Viewpoints.with_name(@attrs["viewpoint"]),
              connection_router_type: @attrs["connectionRouterType"],
              type: @attrs["xsi:type"],
              background: @attrs["background"]
            )
          end

          def on_lang_string(name, _source)
            @diagram_name = name
            false
          end

          def on_view_node(view_node, source)
            @view_nodes << view_node if source.parent_handler == self
            false
          end

          def on_connection(connection, _source)
            @connections << connection
            false
          end
        end
      end
    end
  end
end
