# frozen_string_literal: true

require "scanf"

module Archimate
  module FileFormats
    module Sax
      module Archi
        class Diagram < FileFormats::Sax::Handler
          VIEWPOINT_INDEX = {
            "1" => nil, # DataModel::ViewpointType::Actor_cooperation,
            "2" => DataModel::ViewpointType::Application_behavior,
            "application_cooperation" => DataModel::ViewpointType::Application_cooperation,
            "3" => DataModel::ViewpointType::Application_cooperation,
            "4" => DataModel::ViewpointType::Application_structure,
            "application_usage" => DataModel::ViewpointType::Application_usage,
            "5" => DataModel::ViewpointType::Application_usage,
            "6" => DataModel::ViewpointType::Business_function,
            "business_process_cooperation" => DataModel::ViewpointType::Business_process_cooperation,
            "7" => nil, # DataModel::ViewpointType::Business_cooperation,
            "8" => DataModel::ViewpointType::Business_process,
            "product" => DataModel::ViewpointType::Product,
            "9" => DataModel::ViewpointType::Product,
            "implementation_deployment" => DataModel::ViewpointType::Implementation_and_deployment,
            "10" => DataModel::ViewpointType::Implementation_and_deployment,
            "information_structure" => DataModel::ViewpointType::Information_structure,
            "11" => DataModel::ViewpointType::Information_structure,
            "12" => DataModel::ViewpointType::Infrastructure_usage,
            "13" => DataModel::ViewpointType::Infrastructure,
            "layered" => DataModel::ViewpointType::Layered,
            "14" => DataModel::ViewpointType::Layered,
            "organization" => DataModel::ViewpointType::Organization,
            "15" => DataModel::ViewpointType::Organization,
            "service_realization" => DataModel::ViewpointType::Service_realization,
            "16" => DataModel::ViewpointType::Service_realization,
            "stakeholder" => DataModel::ViewpointType::Stakeholder,
            "17" => DataModel::ViewpointType::Stakeholder,
            "goal_realization" => DataModel::ViewpointType::Goal_realization,
            "18" => DataModel::ViewpointType::Goal_realization,
            "19" => DataModel::ViewpointType::Goal_contribution,
            "20" => DataModel::ViewpointType::Principles,
            "requirements_realization" => DataModel::ViewpointType::Requirements_realization,
            "21" => DataModel::ViewpointType::Requirements_realization,
            "motivation" => DataModel::ViewpointType::Motivation,
            "22" => DataModel::ViewpointType::Motivation,
            "project" => DataModel::ViewpointType::Project,
            "23" => DataModel::ViewpointType::Project,
            "migration" => DataModel::ViewpointType::Migration,
            "24" => DataModel::ViewpointType::Migration,
            "implementation_migration" => DataModel::ViewpointType::Implementation_and_migration,
            "25" => DataModel::ViewpointType::Implementation_and_migration,
            "capability" => nil, # DataModel::ViewpointType::Capability,
            "outcome_realization" => DataModel::ViewpointType::Outcome_realization,
            "physical" => DataModel::ViewpointType::Physical,
            "resource" => nil, # DataModel::ViewpointType::Resource,
            "strategy" => DataModel::ViewpointType::Strategy,
            "technology" => DataModel::ViewpointType::Technology,
            "technology_usage" => DataModel::ViewpointType::Technology_usage
          }

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
              viewpoint: VIEWPOINT_INDEX.fetch(@attrs["viewpoint"], nil),
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

          # @todo delete me
          def parse_viewpoint_type(viewpoint_idx)
            case viewpoint_idx
            when String
              idx = viewpoint_idx.scanf("%d").first
              return nil unless idx
              Serializer::Archi::ViewpointType::values[idx]
            else
              nil
            end
          end
        end
      end
    end
  end
end
