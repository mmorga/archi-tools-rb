# frozen_string_literal: true

require "scanf"

module Archimate
  module FileFormats
    module Sax
      module Archi
        class Diagram < FileFormats::Sax::Handler
          VIEWPOINT_INDEX = {
            "1" => nil, # DataModel::Viewpoints::Actor_cooperation,
            "2" => DataModel::Viewpoints::Application_behavior,
            "application_cooperation" => DataModel::Viewpoints::Application_cooperation,
            "3" => DataModel::Viewpoints::Application_cooperation,
            "4" => DataModel::Viewpoints::Application_structure,
            "application_usage" => DataModel::Viewpoints::Application_usage,
            "5" => DataModel::Viewpoints::Application_usage,
            "6" => DataModel::Viewpoints::Business_function,
            "business_process_cooperation" => DataModel::Viewpoints::Business_process_cooperation,
            "7" => nil, # DataModel::Viewpoints::Business_cooperation,
            "8" => DataModel::Viewpoints::Business_process,
            "product" => DataModel::Viewpoints::Product,
            "9" => DataModel::Viewpoints::Product,
            "implementation_deployment" => DataModel::Viewpoints::Implementation_and_deployment,
            "10" => DataModel::Viewpoints::Implementation_and_deployment,
            "information_structure" => DataModel::Viewpoints::Information_structure,
            "11" => DataModel::Viewpoints::Information_structure,
            "12" => DataModel::Viewpoints::Infrastructure_usage,
            "13" => DataModel::Viewpoints::Infrastructure,
            "layered" => DataModel::Viewpoints::Layered,
            "14" => DataModel::Viewpoints::Layered,
            "organization" => DataModel::Viewpoints::Organization,
            "15" => DataModel::Viewpoints::Organization,
            "service_realization" => DataModel::Viewpoints::Service_realization,
            "16" => DataModel::Viewpoints::Service_realization,
            "stakeholder" => DataModel::Viewpoints::Stakeholder,
            "17" => DataModel::Viewpoints::Stakeholder,
            "goal_realization" => DataModel::Viewpoints::Goal_realization,
            "18" => DataModel::Viewpoints::Goal_realization,
            "19" => DataModel::Viewpoints::Goal_contribution,
            "20" => DataModel::Viewpoints::Principles,
            "requirements_realization" => DataModel::Viewpoints::Requirements_realization,
            "21" => DataModel::Viewpoints::Requirements_realization,
            "motivation" => DataModel::Viewpoints::Motivation,
            "22" => DataModel::Viewpoints::Motivation,
            "project" => DataModel::Viewpoints::Project,
            "23" => DataModel::Viewpoints::Project,
            "migration" => DataModel::Viewpoints::Migration,
            "24" => DataModel::Viewpoints::Migration,
            "implementation_migration" => DataModel::Viewpoints::Implementation_and_migration,
            "25" => DataModel::Viewpoints::Implementation_and_migration,
            "capability" => nil, # DataModel::Viewpoints::Capability,
            "outcome_realization" => DataModel::Viewpoints::Outcome_realization,
            "physical" => DataModel::Viewpoints::Physical,
            "resource" => nil, # DataModel::Viewpoints::Resource,
            "strategy" => DataModel::Viewpoints::Strategy,
            "technology" => DataModel::Viewpoints::Technology,
            "technology_usage" => DataModel::Viewpoints::Technology_usage
          }.freeze

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
        end
      end
    end
  end
end
