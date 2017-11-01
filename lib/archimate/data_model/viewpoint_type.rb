# frozen_string_literal: true

require "ruby-enum"

module Archimate
  module DataModel
    class ViewpointType
      include Ruby::Enum

      ENTITIES = DataModel::Layers.values.flat_map(&:elements)

      CORE_ELEMENTS = [DataModel::Layers::Business, DataModel::Layers::Application, DataModel::Layers::Technology]
                      .flat_map(&:elements)

      DEFAULT_RELATIONS = [
        Relationships::Access,
        Relationships::Aggregation,
        Relationships::Assignment,
        Relationships::Association,
        Relationships::Composition,
        Relationships::Flow,
        Relationships::Realization,
        Relationships::Specialization,
        Relationships::Triggering,
        Relationships::Serving
      ].freeze

      ViewpointTypeVal = Struct.new(:name, :entities, :relations) do
        def to_s
          name
        end
      end

      # Basic Viewpoints
      define :Introductory, ViewpointTypeVal.new("Introductory",
                                                 CORE_ELEMENTS,
                                                 DataModel::Relationships.classes)

      # Category:Composition Viewpoints that defines internal compositions and aggregations of elements.
      define :Organization, ViewpointTypeVal.new("Organization",
                                                 DataModel::ConnectorType.values + %w[
                                                   BusinessActor
                                                   BusinessCollaboration
                                                   BusinessInterface
                                                   BusinessRole
                                                   Location
                                                 ],
                                                 DEFAULT_RELATIONS - [Relationships::Access, Relationships::Realization])

      define :Application_platform, ViewpointTypeVal.new("Application Platform",
                                                         CORE_ELEMENTS,
                                                         DataModel::Relationships.classes)

      define :Information_structure, ViewpointTypeVal.new("Information Structure",
                                                          DataModel::ConnectorType.values + %w[
                                                            Artifact
                                                            BusinessObject
                                                            DataObject
                                                            Meaning
                                                            Representation
                                                          ],
                                                          DEFAULT_RELATIONS - [Relationships::Assignment, Relationships::Serving])

      define :Technology, ViewpointTypeVal.new("Technology",
                                               CORE_ELEMENTS,
                                               DataModel::Relationships.classes)

      define :Layered, ViewpointTypeVal.new("Layered",
                                            ENTITIES + DataModel::ConnectorType.values,
                                            DataModel::Relationships.classes)

      define :Physical, ViewpointTypeVal.new("Physical",
                                             CORE_ELEMENTS,
                                             DataModel::Relationships.classes)

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
                                                     DataModel::Relationships.classes)

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
                                                     [
                                                       Relationships::Aggregation,
                                                       Relationships::Association,
                                                       Relationships::Composition,
                                                       Relationships::Influence,
                                                       Relationships::Realization,
                                                       Relationships::Specialization
                                                     ])

      define :Goal_contribution, ViewpointTypeVal.new("Goal Contribution",
                                                      %w[
                                                        Constraint
                                                        Goal
                                                        Principle
                                                        Requirement
                                                      ],
                                                      [
                                                        Relationships::Aggregation,
                                                        Relationships::Association,
                                                        Relationships::Composition,
                                                        Relationships::Influence,
                                                        Relationships::Realization,
                                                        Relationships::Specialization
                                                      ])

      define :Principles, ViewpointTypeVal.new("Principles",
                                               %w[
                                                 Goal
                                                 Principle
                                               ],
                                               [
                                                 Relationships::Aggregation,
                                                 Relationships::Association,
                                                 Relationships::Composition,
                                                 Relationships::Influence,
                                                 Relationships::Realization,
                                                 Relationships::Specialization
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
                                               [
                                                 Relationships::Aggregation,
                                                 Relationships::Association,
                                                 Relationships::Composition,
                                                 Relationships::Flow,
                                                 Relationships::Influence,
                                                 Relationships::Realization,
                                                 Relationships::Specialization
                                               ])

      # Strategy Viewpoints
      define :Strategy, ViewpointTypeVal.new("Strategy",
                                             CORE_ELEMENTS,
                                             DataModel::Relationships.classes)

      define :Capability_map, ViewpointTypeVal.new("Capability Map",
                                                   CORE_ELEMENTS,
                                                   DataModel::Relationships.classes)

      define :Outcome_realization, ViewpointTypeVal.new("Outcome Realization",
                                                        CORE_ELEMENTS,
                                                        DataModel::Relationships.classes)

      define :Resource_map, ViewpointTypeVal.new("Resource Map",
                                                 CORE_ELEMENTS,
                                                 DataModel::Relationships.classes)

      # Implementation and Migration Viewpoints
      define :Project, ViewpointTypeVal.new("Project",
                                            DataModel::ConnectorType.values + %w[
                                              BusinessActor
                                              BusinessRole
                                              Deliverable
                                              Goal
                                              WorkPackage
                                            ],
                                            DEFAULT_RELATIONS - [Relationships::Access])

      define :Migration, ViewpointTypeVal.new("Migration",
                                              DataModel::ConnectorType.values + %w[Gap Plateau],
                                              [
                                                Relationships::AndJunction,
                                                Relationships::Association,
                                                Relationships::Composition,
                                                Relationships::Flow,
                                                Relationships::Junction,
                                                Relationships::OrJunction,
                                                Relationships::Triggering
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
                                                [
                                                  Relationships::Aggregation,
                                                  Relationships::Association,
                                                  Relationships::Composition,
                                                  Relationships::Influence,
                                                  Relationships::Specialization
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
                                                      DEFAULT_RELATIONS - [Relationships::Access])

      define :Business_function, ViewpointTypeVal.new("Business Function",
                                                      DataModel::ConnectorType.values + %w[
                                                        BusinessActor
                                                        BusinessFunction
                                                        BusinessRole
                                                      ],
                                                      DEFAULT_RELATIONS - [
                                                        Relationships::Access,
                                                        Relationships::Realization
                                                      ])

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
                                                          DEFAULT_RELATIONS - [Relationships::Realization])

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
                                                  DataModel::Relationships.classes)

      def self.[](idx)
        values[idx]
      end
    end

    VIEWPOINT_CONTENT_ENUM = %w[Details Coherence Overview].freeze

    VIEWPOINT_PURPOSE_ENUM = %w[Designing Deciding Informing].freeze
  end
end
