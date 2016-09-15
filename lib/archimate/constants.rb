module Archimate
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
  end
end
