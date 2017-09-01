# frozen_string_literal: true
require "ruby-enum"

module Archimate
  module FileFormats
    module Serializer
      module Archi
        class ViewpointType
          include Ruby::Enum

          define :None, ""
          define :Actor_cooperation, "Actor Co-operation"
          define :Application_behavior, "Application Behavior"
          define :Application_cooperation, "Application Co-operation"
          define :Application_structure, "Application Structure"
          define :Application_usage, "Application Usage"
          define :Business_function, "Business Function"
          define :Business_process_cooperation, "Business Process Co-operation"
          define :Business_process, "Business Process"
          define :Product, "Product"
          define :Implementation_and_deployment, "Implementation and Deployment"
          define :Information_structure, "Information Structure"
          define :Infrastructure_usage, "Infrastructure Usage"
          define :Infrastructure, "Infrastructure"
          define :Layered, "Layered"
          define :Organization, "Organization"
          define :Service_realization, "Service Realization"
          define :Stakeholder, "Stakeholder"
          define :Goal_realization, "Goal Realization"
          define :Goal_contribution, "Goal Contribution"
          define :Principles, "Principles"
          define :Requirements_realization, "Requirements Realization"
          define :Motivation, "Motivation"
          define :Project, "Project"
          define :Migration, "Migration"
          define :Implementation_and_migration, "Implementation and Migration"

          def self.[](idx)
            values[idx]
          end
        end
      end
    end
  end
end
