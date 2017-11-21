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
              viewpoint: viewpoint,
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

          VIEWPOINT_MAP = {
            "Business Process Co-operation" => DataModel::Viewpoints::Business_process_cooperation,
            "Application Co-operation" => DataModel::Viewpoints::Application_cooperation
          }.freeze

          def viewpoint
            viewpoint_attr = @attrs["viewpoint"]&.strip || ""
            return nil if viewpoint_attr.empty?
            return VIEWPOINT_MAP[viewpoint_attr] if VIEWPOINT_MAP.include?(viewpoint_attr)
            DataModel::Viewpoints.with_name(viewpoint_attr)
          end
        end
      end
    end
  end
end
