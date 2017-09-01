# frozen_string_literal: true

require "ruby-enum"

module Archimate
  module DataModel
    class ViewpointType
      include Ruby::Enum

      ENTITIES = DataModel::Layers.values.flat_map(&:elements)

      CORE_ELEMENTS = [DataModel::Layers::Business, DataModel::Layers::Application, DataModel::Layers::Technology]
                      .flat_map(&:elements)

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

      ViewpointTypeVal = Struct.new(:name, :entities, :relations) do
        def to_s
          name
        end
      end

      # Basic Viewpoints
      define :Introductory, ViewpointTypeVal.new("Introductory",
                                                 CORE_ELEMENTS,
                                                 DataModel::RelationshipType.values)

      # Category:Composition Viewpoints that defines internal compositions and aggregations of elements.
      define :Organization, ViewpointTypeVal.new("Organization",
                                                 DataModel::ConnectorType.values + %w[
                                                   BusinessActor
                                                   BusinessCollaboration
                                                   BusinessInterface
                                                   BusinessRole
                                                   Location
                                                 ],
                                                 DEFAULT_RELATIONS - %w[AccessRelationship RealisationRelationship])

      define :Application_platform, ViewpointTypeVal.new("Application Platform",
                                                         CORE_ELEMENTS,
                                                         DataModel::RelationshipType.values)

      define :Information_structure, ViewpointTypeVal.new("Information Structure",
                                                          DataModel::ConnectorType.values + %w[
                                                            Artifact
                                                            BusinessObject
                                                            DataObject
                                                            Meaning
                                                            Representation
                                                          ],
                                                          DEFAULT_RELATIONS - %w[AssignmentRelationship UsedByRelationship])

      define :Technology, ViewpointTypeVal.new("Technology",
                                               CORE_ELEMENTS,
                                               DataModel::RelationshipType.values)

      define :Layered, ViewpointTypeVal.new("Layered",
                                            ENTITIES + DataModel::ConnectorType.values,
                                            DataModel::RelationshipType.values)

      define :Physical, ViewpointTypeVal.new("Physical",
                                             CORE_ELEMENTS,
                                             DataModel::RelationshipType.values)

      # Category:Support Viewpoints where you are looking at elements that are supported by other elements. Typically from one layer and upwards to an above layer.
      define :Product, ViewpointTypeVal.new("Product",
                                            DataModel::ConnectorType.values + %w[
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
                                            DEFAULT_RELATIONS)

      define :Application_usage, ViewpointTypeVal.new("Application Usage",
                                                      DataModel::ConnectorType.values + %w[
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
                                                      DEFAULT_RELATIONS)

      define :Technology_usage, ViewpointTypeVal.new("Technology Usage",
                                                     CORE_ELEMENTS,
                                                     DataModel::RelationshipType.values)

      # Category:Cooperation Towards peer elements which cooperate with each other. Typically across aspects.
      define :Business_process_cooperation, ViewpointTypeVal.new("Business Process Cooperation",
                                                                 DataModel::ConnectorType.values + %w[
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
                                                                 DEFAULT_RELATIONS)

      define :Application_cooperation, ViewpointTypeVal.new("Application Cooperation",
                                                            DataModel::ConnectorType.values + %w[
                                                              ApplicationCollaboration
                                                              ApplicationComponent
                                                              ApplicationFunction
                                                              ApplicationInteraction
                                                              ApplicationInterface
                                                              ApplicationService
                                                              DataObject
                                                              Location
                                                            ],
                                                            DEFAULT_RELATIONS)

      # Category:Realization Viewpoints where you are looking at elements that realize other elements. Typically from one layer and downwards to a below layer.
      define :Service_realization, ViewpointTypeVal.new("Service Realization",
                                                        DataModel::ConnectorType.values + %w[
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
                                                        DEFAULT_RELATIONS)

      define :Implementation_and_deployment, ViewpointTypeVal.new("Implementation and Deployment",
                                                                  DataModel::ConnectorType.values + %w[
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
                                                                  DEFAULT_RELATIONS)

      define :Goal_realization, ViewpointTypeVal.new("Goal Realization",
                                                     %w[
                                                       Constraint
                                                       Goal
                                                       Principle
                                                       Requirement
                                                     ],
                                                     %w[
                                                       AggregationRelationship
                                                       AssociationRelationship
                                                       CompositionRelationship
                                                       InfluenceRelationship
                                                       RealisationRelationship
                                                       SpecialisationRelationship
                                                     ])

      define :Goal_contribution, ViewpointTypeVal.new("Goal Contribution",
                                                      %w[
                                                        Constraint
                                                        Goal
                                                        Principle
                                                        Requirement
                                                      ],
                                                      %w[
                                                        AggregationRelationship
                                                        AssociationRelationship
                                                        CompositionRelationship
                                                        InfluenceRelationship
                                                        RealisationRelationship
                                                        SpecialisationRelationship
                                                      ])

      define :Principles, ViewpointTypeVal.new("Principles",
                                               %w[
                                                 Goal
                                                 Principle
                                               ],
                                               %w[
                                                 AggregationRelationship
                                                 AssociationRelationship
                                                 CompositionRelationship
                                                 InfluenceRelationship
                                                 RealisationRelationship
                                                 SpecialisationRelationship
                                               ])

      define :Requirements_realization, ViewpointTypeVal.new("Requirements Realization",
                                                             CORE_ELEMENTS + DataModel::ConnectorType.values + %w[
                                                               Constraint
                                                               Goal
                                                               Requirement
                                                             ],
                                                             DEFAULT_RELATIONS)

      define :Motivation, ViewpointTypeVal.new("Motivation",
                                               %w[
                                                 Assessment
                                                 Constraint
                                                 Driver
                                                 Goal
                                                 Principle
                                                 Requirement
                                                 Stakeholder
                                               ],
                                               %w[
                                                 AggregationRelationship
                                                 AssociationRelationship
                                                 CompositionRelationship
                                                 FlowRelationship
                                                 InfluenceRelationship
                                                 RealisationRelationship
                                                 SpecialisationRelationship
                                               ])

      # Strategy Viewpoints
      define :Strategy, ViewpointTypeVal.new("Strategy",
                                             CORE_ELEMENTS,
                                             DataModel::RelationshipType.values)

      define :Capability_map, ViewpointTypeVal.new("Capability Map",
                                                   CORE_ELEMENTS,
                                                   DataModel::RelationshipType.values)

      define :Outcome_realization, ViewpointTypeVal.new("Outcome Realization",
                                                        CORE_ELEMENTS,
                                                        DataModel::RelationshipType.values)

      define :Resource_map, ViewpointTypeVal.new("Resource Map",
                                                 CORE_ELEMENTS,
                                                 DataModel::RelationshipType.values)

      # Implementation and Migration Viewpoints
      define :Project, ViewpointTypeVal.new("Project",
                                            DataModel::ConnectorType.values + %w[
                                              BusinessActor
                                              BusinessRole
                                              Deliverable
                                              Goal
                                              WorkPackage
                                            ],
                                            DEFAULT_RELATIONS - %w[AccessRelationship])

      define :Migration, ViewpointTypeVal.new("Migration",
                                              DataModel::ConnectorType.values + %w[Gap Plateau],
                                              %w[
                                                AndJunction
                                                AssociationRelationship
                                                CompositionRelationship
                                                FlowRelationship
                                                Junction
                                                OrJunction
                                                TriggeringRelationship
                                              ])

      define :Implementation_and_migration, ViewpointTypeVal.new("Implementation and Migration",
                                                                 CORE_ELEMENTS + DataModel::ConnectorType.values + %w[
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
                                                                 DEFAULT_RELATIONS)

      # Other Viewpoints
      define :Stakeholder, ViewpointTypeVal.new("Stakeholder",
                                                %w[
                                                  Assessment
                                                  Driver
                                                  Goal
                                                  Stakeholder
                                                ],
                                                %w[
                                                  AggregationRelationship
                                                  AssociationRelationship
                                                  CompositionRelationship
                                                  InfluenceRelationship
                                                  SpecialisationRelationship
                                                ])

      # Other older viewpoints
      define :Actor_cooperation, ViewpointTypeVal.new("Actor Co-operation",
                                                      DataModel::ConnectorType.values + %w[
                                                        ApplicationComponent
                                                        ApplicationInterface
                                                        ApplicationService
                                                        BusinessActor
                                                        BusinessCollaboration
                                                        BusinessInterface
                                                        BusinessRole
                                                        BusinessService
                                                      ],
                                                      DEFAULT_RELATIONS - %w[AccessRelationship])

      define :Business_function, ViewpointTypeVal.new("Business Function",
                                                      DataModel::ConnectorType.values + %w[
                                                        BusinessActor
                                                        BusinessFunction
                                                        BusinessRole
                                                      ],
                                                      DEFAULT_RELATIONS - %w[AccessRelationship RealisationRelationship])

      define :Business_process, ViewpointTypeVal.new("Business Process",
                                                      DataModel::ConnectorType.values + %w[
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
                                                      DEFAULT_RELATIONS)

      define :Application_behavior, ViewpointTypeVal.new("Application Behavior",
                                                         DataModel::ConnectorType.values + %w[
                                                           ApplicationCollaboration
                                                           ApplicationComponent
                                                           ApplicationFunction
                                                           ApplicationInteraction
                                                           ApplicationInterface
                                                           ApplicationService
                                                           DataObject
                                                         ],
                                                         DEFAULT_RELATIONS)

      define :Application_structure, ViewpointTypeVal.new("Application Structure",
                                                          DataModel::ConnectorType.values + %w[
                                                            ApplicationCollaboration
                                                            ApplicationComponent
                                                            ApplicationInterface
                                                            DataObject
                                                          ],
                                                          DEFAULT_RELATIONS - %w[RealisationRelationship])

      define :Infrastructure, ViewpointTypeVal.new("Infrastructure",
                                                   DataModel::ConnectorType.values + %w[
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
                                                   DEFAULT_RELATIONS)

      define :Infrastructure_usage, ViewpointTypeVal.new("Infrastructure Usage",
                                                         DataModel::ConnectorType.values + %w[
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
                                                         DEFAULT_RELATIONS)

      define :Landscape_map, ViewpointTypeVal.new("Landscape Map",
                                                  ENTITIES + DataModel::ConnectorType.values,
                                                  DataModel::RelationshipType.values)

      def self.[](idx)
        values[idx]
      end
    end

    VIEWPOINT_CONTENT_ENUM = %w[Details Coherence Overview].freeze

    VIEWPOINT_PURPOSE_ENUM = %w[Designing Deciding Informing].freeze
  end
end
