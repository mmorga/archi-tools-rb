# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module ModelExchangeFile
        module V21
          module Viewpoint
            VIEWPOINT_MAP = {
              "Business Process Co-operation" => DataModel::Viewpoints::Business_process_cooperation,
              "Application Co-operation" => DataModel::Viewpoints::Application_cooperation
            }.freeze

            def viewpoint_attribute(viewpoint)
              return nil unless viewpoint
              VIEWPOINT_MAP.key(viewpoint) || viewpoint.name.to_s
            end
          end
        end
      end
    end
  end
end
