# frozen_string_literal: true

require "ruby-enum"

module Archimate
  module DataModel
    class ViewpointType
      include Ruby::Enum

      ENTITIES = Elements.classes

      CORE_ELEMENTS = Elements.classes.select do |el|
        [Layers::Business, Layers::Application, Layers::Technology].include?(el::LAYER)
      end

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
      define :Introductory, ViewpointTypeVal.new(
        "Introductory",
        CORE_ELEMENTS,
        Relationships.classes
      )

      # Category:Composition Viewpoints that defines internal compositions and aggregations of elements.
      define :Organization, ViewpointTypeVal.new(
        "Organization",
        ConnectorType.values + [
          Elements::BusinessActor, Elements::BusinessCollaboration,
          Elements::BusinessInterface, Elements::BusinessRole,
          Elements::Location
        ],
        DEFAULT_RELATIONS - [Relationships::Access, Relationships::Realization]
      )

      define :Application_platform, ViewpointTypeVal.new(
        "Application Platform",
        CORE_ELEMENTS,
        Relationships.classes
      )

      define :Information_structure, ViewpointTypeVal.new(
        "Information Structure",
        ConnectorType.values + [
          Elements::Artifact, Elements::BusinessObject, Elements::DataObject,
          Elements::Meaning, Elements::Representation
        ],
        DEFAULT_RELATIONS - [Relationships::Assignment, Relationships::Serving]
      )

      define :Technology, ViewpointTypeVal.new(
        "Technology",
        CORE_ELEMENTS,
        Relationships.classes
      )

      define :Layered, ViewpointTypeVal.new(
        "Layered",
        ENTITIES + ConnectorType.values,
        Relationships.classes
      )

      define :Physical, ViewpointTypeVal.new(
        "Physical",
        CORE_ELEMENTS,
        Relationships.classes
      )

      # Category:Support Viewpoints where you are looking at elements that are
      # supported by other elements. Typically from one layer and upwards to an
      # above layer.
      define :Product, ViewpointTypeVal.new(
        "Product",
        ConnectorType.values + [
          Elements::ApplicationComponent, Elements::ApplicationInterface,
          Elements::ApplicationService, Elements::BusinessActor,
          Elements::BusinessEvent, Elements::BusinessFunction,
          Elements::BusinessInteraction, Elements::BusinessInterface,
          Elements::BusinessProcess, Elements::BusinessRole,
          Elements::BusinessService, Elements::Contract,
          Elements::Product, Elements::Value
        ],
        DEFAULT_RELATIONS
      )

      define :Application_usage, ViewpointTypeVal.new(
        "Application Usage",
        ConnectorType.values + [
          Elements::ApplicationCollaboration, Elements::ApplicationComponent,
          Elements::ApplicationInterface, Elements::ApplicationService,
          Elements::BusinessEvent, Elements::BusinessFunction,
          Elements::BusinessInteraction, Elements::BusinessObject,
          Elements::BusinessProcess, Elements::BusinessRole,
          Elements::DataObject
        ],
        DEFAULT_RELATIONS
      )

      define :Technology_usage, ViewpointTypeVal.new(
        "Technology Usage",
        CORE_ELEMENTS,
        Relationships.classes
      )

      # Category:Cooperation Towards peer elements which cooperate with each
      # other. Typically across aspects.
      define :Business_process_cooperation, ViewpointTypeVal.new(
        "Business Process Cooperation",
        ConnectorType.values + [
          Elements::ApplicationService, Elements::BusinessActor,
          Elements::BusinessCollaboration, Elements::BusinessEvent,
          Elements::BusinessFunction, Elements::BusinessInteraction,
          Elements::BusinessObject, Elements::BusinessProcess,
          Elements::BusinessRole, Elements::BusinessService,
          Elements::Location, Elements::Representation
        ],
        DEFAULT_RELATIONS
      )

      define :Application_cooperation, ViewpointTypeVal.new(
        "Application Cooperation",
        ConnectorType.values + [
          Elements::ApplicationCollaboration, Elements::ApplicationComponent,
          Elements::ApplicationFunction, Elements::ApplicationInteraction,
          Elements::ApplicationInterface, Elements::ApplicationService,
          Elements::DataObject, Elements::Location
        ],
        DEFAULT_RELATIONS
      )

      # Category:Realization Viewpoints where you are looking at elements that
      # realize other elements. Typically from one layer and downwards to a
      # below layer.
      define :Service_realization, ViewpointTypeVal.new(
        "Service Realization",
        ConnectorType.values + [
          Elements::ApplicationCollaboration, Elements::ApplicationComponent,
          Elements::ApplicationService, Elements::BusinessActor,
          Elements::BusinessCollaboration, Elements::BusinessEvent,
          Elements::BusinessFunction, Elements::BusinessInteraction,
          Elements::BusinessObject, Elements::BusinessProcess,
          Elements::BusinessRole, Elements::BusinessService,
          Elements::DataObject
        ],
        DEFAULT_RELATIONS
      )

      define :Implementation_and_deployment, ViewpointTypeVal.new(
        "Implementation and Deployment",
        ConnectorType.values + [
          Elements::ApplicationCollaboration, Elements::ApplicationComponent,
          Elements::Artifact, Elements::CommunicationPath,
          Elements::DataObject, Elements::Device,
          Elements::InfrastructureService, Elements::Network, Elements::Node,
          Elements::SystemSoftware
        ],
        DEFAULT_RELATIONS
      )

      define :Goal_realization, ViewpointTypeVal.new(
        "Goal Realization",
        [
          Elements::Constraint, Elements::Goal, Elements::Principle,
          Elements::Requirement
        ],
        [
          Relationships::Aggregation, Relationships::Association,
          Relationships::Composition, Relationships::Influence,
          Relationships::Realization, Relationships::Specialization
        ]
      )

      define :Goal_contribution, ViewpointTypeVal.new(
        "Goal Contribution",
        [
          Elements::Constraint, Elements::Goal, Elements::Principle,
          Elements::Requirement
        ],
        [
          Relationships::Aggregation, Relationships::Association,
          Relationships::Composition, Relationships::Influence,
          Relationships::Realization, Relationships::Specialization
        ]
      )

      define :Principles, ViewpointTypeVal.new(
        "Principles",
        [Elements::Goal, Elements::Principle],
        [
          Relationships::Aggregation, Relationships::Association,
          Relationships::Composition, Relationships::Influence,
          Relationships::Realization, Relationships::Specialization
        ]
      )

      define :Requirements_realization, ViewpointTypeVal.new(
        "Requirements Realization",
        CORE_ELEMENTS + ConnectorType.values + [
          Elements::Constraint, Elements::Goal, Elements::Requirement
        ],
        DEFAULT_RELATIONS
      )

      define :Motivation, ViewpointTypeVal.new(
        "Motivation",
        [
          Elements::Assessment, Elements::Constraint, Elements::Driver,
          Elements::Goal, Elements::Principle, Elements::Requirement,
          Elements::Stakeholder
        ],
        [
          Relationships::Aggregation, Relationships::Association,
          Relationships::Composition, Relationships::Flow,
          Relationships::Influence, Relationships::Realization,
          Relationships::Specialization
        ]
      )

      # Strategy Viewpoints
      define :Strategy, ViewpointTypeVal.new(
        "Strategy", CORE_ELEMENTS, Relationships.classes
      )

      define :Capability_map, ViewpointTypeVal.new(
        "Capability Map", CORE_ELEMENTS, Relationships.classes
      )

      define :Outcome_realization, ViewpointTypeVal.new(
        "Outcome Realization", CORE_ELEMENTS, Relationships.classes
      )

      define :Resource_map, ViewpointTypeVal.new(
        "Resource Map", CORE_ELEMENTS, Relationships.classes
      )

      # Implementation and Migration Viewpoints
      define :Project, ViewpointTypeVal.new(
        "Project",
        ConnectorType.values + [
          Elements::BusinessActor, Elements::BusinessRole,
          Elements::Deliverable, Elements::Goal, Elements::WorkPackage
        ],
        DEFAULT_RELATIONS - [Relationships::Access]
      )

      define :Migration, ViewpointTypeVal.new(
        "Migration",
        ConnectorType.values + [Elements::Gap, Elements::Plateau],
        [
          Relationships::AndJunction, Relationships::Association,
          Relationships::Composition, Relationships::Flow,
          Relationships::Junction, Relationships::OrJunction,
          Relationships::Triggering
        ]
      )

      define :Implementation_and_migration, ViewpointTypeVal.new(
        "Implementation and Migration",
        CORE_ELEMENTS + ConnectorType.values + [
          Elements::Location, Elements::Requirement, Elements::Constraint,
          Elements::Goal, Elements::BusinessRole, Elements::WorkPackage,
          Elements::Deliverable, Elements::BusinessActor, Elements::Plateau,
          Elements::Gap
        ],
        DEFAULT_RELATIONS
      )

      # Other Viewpoints
      define :Stakeholder, ViewpointTypeVal.new(
        "Stakeholder",
        [
          Elements::Assessment, Elements::Driver, Elements::Goal,
          Elements::Stakeholder
        ],
        [
          Relationships::Aggregation, Relationships::Association,
          Relationships::Composition, Relationships::Influence,
          Relationships::Specialization
        ]
      )

      # Other older viewpoints
      define :Actor_cooperation, ViewpointTypeVal.new(
        "Actor Co-operation",
        ConnectorType.values + [
          Elements::ApplicationComponent, Elements::ApplicationInterface,
          Elements::ApplicationService, Elements::BusinessActor,
          Elements::BusinessCollaboration, Elements::BusinessInterface,
          Elements::BusinessRole, Elements::BusinessService
        ],
        DEFAULT_RELATIONS - [Relationships::Access]
      )

      define :Business_function, ViewpointTypeVal.new(
        "Business Function",
        ConnectorType.values + [
          Elements::BusinessActor, Elements::BusinessFunction,
          Elements::BusinessRole
        ],
        DEFAULT_RELATIONS - [Relationships::Access, Relationships::Realization]
      )

      define :Business_process, ViewpointTypeVal.new(
        "Business Process",
        ConnectorType.values + [
          Elements::ApplicationService, Elements::BusinessActor,
          Elements::BusinessCollaboration, Elements::BusinessEvent,
          Elements::BusinessFunction, Elements::BusinessInteraction,
          Elements::BusinessObject, Elements::BusinessProcess,
          Elements::BusinessRole, Elements::BusinessService,
          Elements::Location, Elements::Representation
        ],
        DEFAULT_RELATIONS
      )

      define :Application_behavior, ViewpointTypeVal.new(
        "Application Behavior",
        ConnectorType.values + [
          Elements::ApplicationCollaboration, Elements::ApplicationComponent,
          Elements::ApplicationFunction, Elements::ApplicationInteraction,
          Elements::ApplicationInterface, Elements::ApplicationService,
          Elements::DataObject
        ],
        DEFAULT_RELATIONS
      )

      define :Application_structure, ViewpointTypeVal.new(
        "Application Structure",
        ConnectorType.values + [
          Elements::ApplicationCollaboration, Elements::ApplicationComponent,
          Elements::ApplicationInterface, Elements::DataObject
        ],
        DEFAULT_RELATIONS - [Relationships::Realization]
      )

      define :Infrastructure, ViewpointTypeVal.new(
        "Infrastructure",
        ConnectorType.values + [
          Elements::Artifact, Elements::CommunicationPath, Elements::Device,
          Elements::InfrastructureFunction, Elements::InfrastructureInterface,
          Elements::InfrastructureService, Elements::Location,
          Elements::Network, Elements::Node, Elements::SystemSoftware
        ],
        DEFAULT_RELATIONS
      )

      define :Infrastructure_usage, ViewpointTypeVal.new(
        "Infrastructure Usage",
        ConnectorType.values + [
          Elements::ApplicationComponent, Elements::ApplicationFunction,
          Elements::CommunicationPath, Elements::Device,
          Elements::InfrastructureFunction, Elements::InfrastructureInterface,
          Elements::InfrastructureService, Elements::Network, Elements::Node,
          Elements::SystemSoftware
        ],
        DEFAULT_RELATIONS
      )

      define :Landscape_map, ViewpointTypeVal.new(
        "Landscape Map", ENTITIES + ConnectorType.values, Relationships.classes
      )

      def self.[](idx)
        values[idx]
      end
    end

    VIEWPOINT_CONTENT_ENUM = %w[Details Coherence Overview].freeze

    VIEWPOINT_PURPOSE_ENUM = %w[Designing Deciding Informing].freeze
  end
end
