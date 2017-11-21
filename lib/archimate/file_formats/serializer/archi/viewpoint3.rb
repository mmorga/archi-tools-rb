# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module Archi
        module Viewpoint3
          VIEWPOINT_INDEX = {
            # nil => "1", # DataModel::Viewpoints::Actor_cooperation,
            DataModel::Viewpoints::Application_behavior => "2",
            DataModel::Viewpoints::Application_cooperation => "3",
            DataModel::Viewpoints::Application_structure => "4",
            DataModel::Viewpoints::Application_usage => "5",
            DataModel::Viewpoints::Business_function => "6",
            # nil => "7", # DataModel::Viewpoints::Business_cooperation,
            DataModel::Viewpoints::Business_process => "8",
            DataModel::Viewpoints::Product => "9",
            DataModel::Viewpoints::Implementation_and_deployment => "10",
            DataModel::Viewpoints::Information_structure => "11",
            DataModel::Viewpoints::Infrastructure_usage => "12",
            DataModel::Viewpoints::Infrastructure => "13",
            DataModel::Viewpoints::Layered => "14",
            DataModel::Viewpoints::Organization => "15",
            DataModel::Viewpoints::Service_realization => "16",
            DataModel::Viewpoints::Stakeholder => "17",
            DataModel::Viewpoints::Goal_realization => "18",
            DataModel::Viewpoints::Goal_contribution => "19",
            DataModel::Viewpoints::Principles => "20",
            DataModel::Viewpoints::Requirements_realization => "21",
            DataModel::Viewpoints::Motivation => "22",
            DataModel::Viewpoints::Project => "23",
            DataModel::Viewpoints::Migration => "24",
            DataModel::Viewpoints::Implementation_and_migration => "25"
          }.freeze

          def serialize_viewpoint(viewpoint)
            VIEWPOINT_INDEX.fetch(viewpoint, nil)
          end
        end
      end
    end
  end
end
