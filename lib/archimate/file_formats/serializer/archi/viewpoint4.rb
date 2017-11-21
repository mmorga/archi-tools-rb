# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module Archi
        module Viewpoint4
          VIEWPOINT_INDEX = {
            DataModel::Viewpoints::Application_cooperation => "application_cooperation",
            DataModel::Viewpoints::Application_usage => "application_usage",
            DataModel::Viewpoints::Business_process_cooperation => "business_process_cooperation",
            DataModel::Viewpoints::Product => "product",
            DataModel::Viewpoints::Implementation_and_deployment => "implementation_deployment",
            DataModel::Viewpoints::Information_structure => "information_structure",
            DataModel::Viewpoints::Layered => "layered",
            DataModel::Viewpoints::Organization => "organization",
            DataModel::Viewpoints::Service_realization => "service_realization",
            DataModel::Viewpoints::Stakeholder => "stakeholder",
            DataModel::Viewpoints::Goal_realization => "goal_realization",
            DataModel::Viewpoints::Requirements_realization => "requirements_realization",
            DataModel::Viewpoints::Motivation => "motivation",
            DataModel::Viewpoints::Project => "project",
            DataModel::Viewpoints::Migration => "migration",
            DataModel::Viewpoints::Implementation_and_migration => "implementation_migration",
            # DataModel::Viewpoints::Capability => "capability",
            DataModel::Viewpoints::Outcome_realization => "outcome_realization",
            DataModel::Viewpoints::Physical => "physical",
            # DataModel::Viewpoints::Resource => "resource",
            DataModel::Viewpoints::Strategy => "strategy",
            DataModel::Viewpoints::Technology => "technology",
            DataModel::Viewpoints::Technology_usage => "technology_usage"
          }.freeze

          def serialize_viewpoint(viewpoint)
            VIEWPOINT_INDEX.fetch(viewpoint, nil)
          end
        end
      end
    end
  end
end
