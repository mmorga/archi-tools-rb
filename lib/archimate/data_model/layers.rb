# frozen_string_literal: true
require "ruby-enum"

module Archimate
  module DataModel
    class Layers
      include Ruby::Enum

      define :Strategy, Layer.new("Strategy", %w[Capability CourseOfAction Resource])

      define :Business, Layer.new("Business", %w[BusinessActor BusinessCollaboration
             BusinessEvent BusinessFunction
             BusinessInteraction BusinessInterface
             BusinessObject BusinessProcess
             BusinessRole BusinessService
             Contract Location
             Meaning Value
             Product Representation])

      define :Application, Layer.new("Application", %w[ApplicationCollaboration ApplicationComponent
             ApplicationFunction ApplicationInteraction
             ApplicationInterface ApplicationService
             DataObject ApplicationProcess ApplicationEvent])

      define :Technology, Layer.new("Technology", %w[Artifact CommunicationPath
             Device InfrastructureFunction
             InfrastructureInterface InfrastructureService
             Network Node SystemSoftware TechnologyCollaboration
             TechnologyInterface Path CommunicationNetwork
             TechnologyFunction TechnologyProcess TechnologyInteraction
             TechnologyEvent TechnologyService
             TechnologyObject])

      define :Physical, Layer.new("Physical", %w[Equipment Facility DistributionNetwork Material])

      define :Motivation, Layer.new("Motivation", %w[Assessment Constraint Driver
             Goal Principle Requirement
             Stakeholder Outcome])

      define :Implementation_and_migration, Layer.new("Implementation and Migration", %w[Deliverable Gap Plateau
             WorkPackage ImplementationEvent])

      # TODO: Is Connectors used? Should this be none?
      define :Connectors, Layer.new("Connectors", %w[AndJunction Junction OrJunction])

      define :None, Layer.new("None")

      # def [](name_or_sym)
      #   case name_or_sym
      #   when Integer
      #     @layers[name_or_sym]
      #   else
      #     @layers.find { |layer| layer === name_or_sym }
      #   end
      # end

      def self.for_element(type)
        values.find { |layer| layer.elements.include?(type) } || Layers::None
      end
    end
  end
end
