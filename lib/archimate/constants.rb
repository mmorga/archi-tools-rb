# frozen_string_literal: true
module Archimate
  # The Constants module contains constants for ArchiMate standards
  # TODO: This should be namespaced for the ArchiMate version in effect
  module Constants
    ELEMENTS = %w(BuinessActor BusinessCollaboration BusinessEvent BusinessFunction
                  BusinessInteraction BusinessInterface BusinessObject BusinessProcess
                  BusinessRole BusinessService Contract Location Meaning Value Product
                  Representation ApplicationCollaboration ApplicationComponent
                  ApplicationFunction ApplicationInteraction ApplicationInterface
                  ApplicationService DataObject Artifact CommunicationPath Device
                  InfrastructureFunction InfrastructureInterface InfrastructureService
                  Network Node SystemSoftware Assessment Constraint Driver Goal Principle
                  Requirement Stakeholder Deliverable Gap Plateau WorkPackage AndJunction
                  Junction OrJunction).freeze

    RELATIONSHIPS = %w(AssociationRelationship AccessRelationship UsedByRelationship
                       RealisationRelationship AssignmentRelationship AggregationRelationship
                       CompositionRelationship FlowRelationship TriggeringRelationship
                       GroupingRelationship SpecialisationRelationship InfluenceRelationship).freeze

    LAYER_ELEMENTS = {
      "Business" =>
        %w(BusinessActor BusinessCollaboration
           BusinessEvent BusinessFunction
           BusinessInteraction BusinessInterface
           BusinessObject BusinessProcess
           BusinessRole BusinessService
           Contract Location
           Meaning Value
           Product Representation),
      "Application" =>
        %w(ApplicationCollaboration ApplicationComponent
           ApplicationFunction ApplicationInteraction
           ApplicationInterface ApplicationService
           DataObject),
      "Technology" =>
        %w(Artifact CommunicationPath
           Device InfrastructureFunction
           InfrastructureInterface InfrastructureService
           Network Node SystemSoftware),
      "Motivation" =>
        %w(Assessment Constraint Driver
           Goal Principle Requirement
           Stakeholder),
      "Implementation and Migration" =>
        %w(Deliverable Gap Plateau
           WorkPackage),
      "Connectors" =>
        %w(AndJunction Junction OrJunction)
    }.freeze

    ELEMENT_LAYER = LAYER_ELEMENTS.each_with_object({}) do |(layer, elements), el_layer_hash|
      elements.each_with_object(el_layer_hash) { |element, a| a[element] = layer }
    end
  end
end
