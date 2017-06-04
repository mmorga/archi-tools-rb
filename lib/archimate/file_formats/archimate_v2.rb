# frozen_string_literal: true

module Archimate
  module FileFormats
    module ArchimateV2
      LAYER_ENTITIES = {
        "Business" => %w[
          BusinessActor
          BusinessCollaboration
          BusinessEvent
          BusinessFunction
          BusinessInteraction
          BusinessInterface
          BusinessObject
          BusinessProcess
          BusinessRole
          BusinessService
          Contract
          Location
          Meaning
          Value
          Product
          Representation
        ].freeze,
        "Application" => %w[
          ApplicationCollaboration
          ApplicationComponent
          ApplicationFunction
          ApplicationInteraction
          ApplicationInterface
          ApplicationService
          DataObject
        ].freeze,
        "Technology" => %w[
          Artifact
          CommunicationPath
          Device
          InfrastructureFunction
          InfrastructureInterface
          InfrastructureService
          Network
          Node
          SystemSoftware
        ].freeze,
        "Motivation" => %w[
          Assessment
          Constraint
          Driver
          Goal
          Principle
          Requirement
          Stakeholder
        ].freeze,
        "Implementation and Migration" => %w[
          Deliverable
          Gap
          Plateau
          WorkPackage
        ].freeze
      }.freeze

      ENTITIES = LAYER_ENTITIES.values.flatten.freeze

      CORE_ELEMENTS = %w[Business Application Technology]
                      .map { |layer| LAYER_ENTITIES[layer] }
                      .inject([]) { |memo, obj| memo.concat(obj) }

      CONNECTORS = %w[
        AndJunction
        Junction
        OrJunction
      ].freeze

      RELATIONS = %w[
        AccessRelationship
        AggregationRelationship
        AssignmentRelationship
        AssociationRelationship
        CompositionRelationship
        FlowRelationship
        InfluenceRelationship
        RealisationRelationship
        SpecialisationRelationship
        TriggeringRelationship
        UsedByRelationship
      ].freeze

      DEFAULT_RELATIONS = %w[
        AccessRelationship
        AggregationRelationship
        AssignmentRelationship
        AssociationRelationship
        CompositionRelationship
        FlowRelationship
        RealisationRelationship
        SpecialisationRelationship
        TriggeringRelationship
        UsedByRelationship
      ].freeze

      RELATION_VERBS = {
        "AccessRelationship" => "accesses",
        "AggregationRelationship" => "aggregates",
        "AssignmentRelationship" => "is assigned to",
        "AssociationRelationship" => "is associated with",
        "CompositionRelationship" => "composes",
        "FlowRelationship" => "flows to",
        "InfluenceRelationship" => "influenecs",
        "RealisationRelationship" => "realizes",
        "SpecialisationRelationship" => "specializes",
        "TriggeringRelationship" => "triggers",
        "UsedByRelationship" => "is used by"
      }.freeze

      VIEWPOINTS = {
        "Introductory" => { entities: CORE_ELEMENTS, relations: RELATIONS },
        "Organization" => {
          entities: CONNECTORS + %w[
            BusinessActor
            BusinessCollaboration
            BusinessInterface
            BusinessRole
            Location
          ],
          relations: DEFAULT_RELATIONS - %w[AccessRelationship RealisationRelationship]
        },
        "Actor Co-operation" => {
          entities: CONNECTORS + %w[
            ApplicationComponent
            ApplicationInterface
            ApplicationService
            BusinessActor
            BusinessCollaboration
            BusinessInterface
            BusinessRole
            BusinessService
          ],
          relations: DEFAULT_RELATIONS - %w[AccessRelationship]
        },
        "Business Function" => {
          entities: CONNECTORS + %w[
            BusinessActor
            BusinessFunction
            BusinessRole
          ],
          relations: DEFAULT_RELATIONS - %w[AccessRelationship RealisationRelationship]
        },
        "Business Process" => {
          entities: CONNECTORS + %w[
            ApplicationService
            BusinessActor
            BusinessCollaboration
            BusinessEvent
            BusinessFunction
            BusinessInteraction
            BusinessObject
            BusinessProcess
            BusinessRole
            BusinessService
            Location
            Representation
          ],
          relations: DEFAULT_RELATIONS
        },
        "Business Process Co-operation" => {
          entities: CONNECTORS + %w[
            ApplicationService
            BusinessActor
            BusinessCollaboration
            BusinessEvent
            BusinessFunction
            BusinessInteraction
            BusinessObject
            BusinessProcess
            BusinessRole
            BusinessService
            Location
            Representation
          ],
          relations: DEFAULT_RELATIONS
        },
        "Product" => {
          entities: CONNECTORS + %w[
            ApplicationComponent
            ApplicationInterface
            ApplicationService
            BusinessActor
            BusinessEvent
            BusinessFunction
            BusinessInteraction
            BusinessInterface
            BusinessProcess
            BusinessRole
            BusinessService
            Contract
            Product
            Value
          ],
          relations: DEFAULT_RELATIONS
        },
        "Application Behavior" => {
          entities: CONNECTORS + %w[
            ApplicationCollaboration
            ApplicationComponent
            ApplicationFunction
            ApplicationInteraction
            ApplicationInterface
            ApplicationService
            DataObject
          ],
          relations: DEFAULT_RELATIONS
        },
        "Application Co-operation" => {
          entities: CONNECTORS + %w[
            ApplicationCollaboration
            ApplicationComponent
            ApplicationFunction
            ApplicationInteraction
            ApplicationInterface
            ApplicationService
            DataObject
            Location
          ],
          relations: DEFAULT_RELATIONS
        },
        "Application Structure" => {
          entities: CONNECTORS + %w[
            ApplicationCollaboration
            ApplicationComponent
            ApplicationInterface
            DataObject
          ],
          relations: DEFAULT_RELATIONS - %w[RealisationRelationship]
        },
        "Application Usage" => {
          entities: CONNECTORS + %w[
            ApplicationCollaboration
            ApplicationComponent
            ApplicationInterface
            ApplicationService
            BusinessEvent
            BusinessFunction
            BusinessInteraction
            BusinessObject
            BusinessProcess
            BusinessRole
            DataObject
          ],
          relations: DEFAULT_RELATIONS
        },
        "Infrastructure" => {
          entities: CONNECTORS + %w[
            Artifact
            CommunicationPath
            Device
            InfrastructureFunction
            InfrastructureInterface
            InfrastructureService
            Location
            Network
            Node
            SystemSoftware
          ],
          relations: DEFAULT_RELATIONS
        },
        "Infrastructure Usage" => {
          entities: CONNECTORS + %w[
            ApplicationComponent
            ApplicationFunction
            CommunicationPath
            Device
            InfrastructureFunction
            InfrastructureInterface
            InfrastructureService
            Network
            Node
            SystemSoftware
          ],
          relations: DEFAULT_RELATIONS
        },
        "Implementation and Deployment" => {
          entities: CONNECTORS + %w[
            ApplicationCollaboration
            ApplicationComponent
            Artifact
            CommunicationPath
            DataObject
            Device
            InfrastructureService
            Network
            Node
            SystemSoftware
          ],
          relations: DEFAULT_RELATIONS
        },
        "Information Structure" => {
          entities: CONNECTORS + %w[
            Artifact
            BusinessObject
            DataObject
            Meaning
            Representation
          ],
          relations: DEFAULT_RELATIONS - %w[AssignmentRelationship UsedByRelationship]
        },
        "Service Realization" => {
          entities: CONNECTORS + %w[
            ApplicationCollaboration
            ApplicationComponent
            ApplicationService
            BusinessActor
            BusinessCollaboration
            BusinessEvent
            BusinessFunction
            BusinessInteraction
            BusinessObject
            BusinessProcess
            BusinessRole
            BusinessService
            DataObject
          ],
          relations: DEFAULT_RELATIONS
        },
        "Layered" => {
          entities: ENTITIES + CONNECTORS,
          relations: RELATIONS
        },
        "Landscape Map" => {
          entities: ENTITIES + CONNECTORS,
          relations: RELATIONS
        },
        "Stakeholder" => {
          entities: %w[
            Assessment
            Driver
            Goal
            Stakeholder
          ],
          relations: %w[
            AggregationRelationship
            AssociationRelationship
            CompositionRelationship
            InfluenceRelationship
            SpecialisationRelationship
          ]
        },
        "Goal Realization" => {
          entities: %w[
            Constraint
            Goal
            Principle
            Requirement
          ],
          relations: %w[
            AggregationRelationship
            AssociationRelationship
            CompositionRelationship
            InfluenceRelationship
            RealisationRelationship
            SpecialisationRelationship
          ]
        },
        "Goal Contribution" => {
          entities: %w[
            Constraint
            Goal
            Principle
            Requirement
          ],
          relations: %w[
            AggregationRelationship
            AssociationRelationship
            CompositionRelationship
            InfluenceRelationship
            RealisationRelationship
            SpecialisationRelationship
          ]
        },
        "Principles" => {
          entities: %w[
            Goal
            Principle
          ],
          relations: %w[
            AggregationRelationship
            AssociationRelationship
            CompositionRelationship
            InfluenceRelationship
            RealisationRelationship
            SpecialisationRelationship
          ]
        },
        "Requirements Realization" => {
          entities: CORE_ELEMENTS + CONNECTORS + %w[
            Constraint
            Goal
            Requirement
          ],
          relations: DEFAULT_RELATIONS
        },
        "Motivation" => {
          entities: %w[
            Assessment
            Constraint
            Driver
            Goal
            Principle
            Requirement
            Stakeholder
          ],
          relations: %w[
            AggregationRelationship
            AssociationRelationship
            CompositionRelationship
            FlowRelationship
            InfluenceRelationship
            RealisationRelationship
            SpecialisationRelationship
          ]
        },
        "Project" => {
          entities: CONNECTORS + %w[
            BusinessActor
            BusinessRole
            Deliverable
            Goal
            WorkPackage
          ],
          relations: DEFAULT_RELATIONS - %w[AccessRelationship]
        },
        "Migration" => {
          entities: CONNECTORS + %w[Gap Plateau],
          relations: %w[
            AndJunction
            AssociationRelationship
            CompositionRelationship
            FlowRelationship
            Junction
            OrJunction
            TriggeringRelationship
          ]
        },
        "Implementation and Migration" => {
          entities: CORE_ELEMENTS + CONNECTORS + %w[
            Location
            Requirement
            Constraint
            Goal
            BusinessRole
            WorkPackage
            Deliverable
            BusinessActor
            Plateau
            Gap
          ],
          relations: DEFAULT_RELATIONS
        }
      }.freeze
    end
  end
end
