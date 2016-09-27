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

    LAYER_ELEMENTS = {
      "Business" =>
        [ "archimate:BusinessActor", "archimate:BusinessCollaboration",
          "archimate:BusinessEvent", "archimate:BusinessFunction",
          "archimate:BusinessInteraction", "archimate:BusinessInterface",
          "archimate:BusinessObject", "archimate:BusinessProcess",
          "archimate:BusinessRole", "archimate:BusinessService",
          "archimate:Contract", "archimate:Location",
          "archimate:Meaning", "archimate:Value",
          "archimate:Product", "archimate:Representation"
        ],
      "Application" =>
        [ "archimate:ApplicationCollaboration", "archimate:ApplicationComponent",
          "archimate:ApplicationFunction", "archimate:ApplicationInteraction",
          "archimate:ApplicationInterface", "archimate:ApplicationService",
          "archimate:DataObject"
        ],
      "Technology" =>
        [ "archimate:Artifact", "archimate:CommunicationPath",
          "archimate:Device", "archimate:InfrastructureFunction",
          "archimate:InfrastructureInterface", "archimate:InfrastructureService",
          "archimate:Network", "archimate:Node", "archimate:SystemSoftware"
        ],
      "Motivation" =>
        [ "archimate:Assessment", "archimate:Constraint", "archimate:Driver",
          "archimate:Goal", "archimate:Principle", "archimate:Requirement",
          "archimate:Stakeholder"
        ],
      "Implementation and Migration" =>
        [ "archimate:Deliverable", "archimate:Gap", "archimate:Plateau",
          "archimate:WorkPackage"
        ],
      "Connectors" =>
        [ "archimate:AndJunction", "archimate:Junction", "archimate:OrJunction"]
    }

    ELEMENT_LAYER = LAYER_ELEMENTS.each_with_object({}) do |(layer, elements), el_layer_hash|
      elements.each_with_object(el_layer_hash) { |element, a| a[element] = layer }
    end
  end
end
