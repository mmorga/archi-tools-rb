# frozen_string_literal: true

require "ruby-enum"

module Archimate
  module DataModel
    # This module contains an enumeration of built-in ArchiMate viewpoint
    # types. These viewpoints are a summary of the viewpoint types defined
    # in ArchiMate versions 2 and 3.
    class Viewpoints
      include Ruby::Enum

      # Basic Viewpoints
      define :Introductory, Viewpoint.new(
        id: "VIEWPOINT-INTRODUCTORY",
        name: "Introductory",
        allowed_element_types: Elements.core_elements,
        allowed_relationship_types: Relationships.classes
      )

      # Category:Composition Viewpoints that defines internal compositions and aggregations of elements.
      define :Organization, Viewpoint.new(
        id: "VIEWPOINT-ORGANIZATION",
        name: "Organization",
        allowed_element_types: ConnectorType.values + [
          Elements::BusinessActor, Elements::BusinessCollaboration,
          Elements::BusinessInterface, Elements::BusinessRole,
          Elements::Location
        ],
        allowed_relationship_types: Relationships.default - [Relationships::Access, Relationships::Realization]
      )

      define :Application_platform, Viewpoint.new(
        id: "VIEWPOINT-APPLICATION_PLATFORM",
        name: "Application Platform",
        allowed_element_types: Elements.core_elements,
        allowed_relationship_types: Relationships.classes
      )

      define :Information_structure, Viewpoint.new(
        id: "VIEWPOINT-INFORMATION_STRUCTURE",
        name: "Information Structure",
        allowed_element_types: ConnectorType.values + [
          Elements::Artifact, Elements::BusinessObject, Elements::DataObject,
          Elements::Meaning, Elements::Representation
        ],
        allowed_relationship_types: Relationships.default - [Relationships::Assignment, Relationships::Serving]
      )

      define :Technology, Viewpoint.new(
        id: "VIEWPOINT-TECHNOLOGY",
        name: "Technology",
        allowed_element_types: Elements.core_elements,
        allowed_relationship_types: Relationships.classes
      )

      define :Layered, Viewpoint.new(
        id: "VIEWPOINT-LAYERED",
        name: "Layered",
        allowed_element_types: Elements.classes + ConnectorType.values,
        allowed_relationship_types: Relationships.classes
      )

      define :Physical, Viewpoint.new(
        id: "VIEWPOINT-PHYSICAL",
        name: "Physical",
        allowed_element_types: Elements.core_elements,
        allowed_relationship_types: Relationships.classes
      )

      # Category:Support Viewpoints where you are looking at elements that are
      # supported by other elements. Typically from one layer and upwards to an
      # above layer.
      define :Product, Viewpoint.new(
        id: "VIEWPOINT-PRODUCT",
        name: "Product",
        allowed_element_types: ConnectorType.values + [
          Elements::ApplicationComponent, Elements::ApplicationInterface,
          Elements::ApplicationService, Elements::BusinessActor,
          Elements::BusinessEvent, Elements::BusinessFunction,
          Elements::BusinessInteraction, Elements::BusinessInterface,
          Elements::BusinessProcess, Elements::BusinessRole,
          Elements::BusinessService, Elements::Contract,
          Elements::Product, Elements::Value
        ],
        allowed_relationship_types: Relationships.default
      )

      define :Application_usage, Viewpoint.new(
        id: "VIEWPOINT-APPLICATION_USAGE",
        name: "Application Usage",
        allowed_element_types: ConnectorType.values + [
          Elements::ApplicationCollaboration, Elements::ApplicationComponent,
          Elements::ApplicationInterface, Elements::ApplicationService,
          Elements::BusinessEvent, Elements::BusinessFunction,
          Elements::BusinessInteraction, Elements::BusinessObject,
          Elements::BusinessProcess, Elements::BusinessRole,
          Elements::DataObject
        ],
        allowed_relationship_types: Relationships.default
      )

      define :Technology_usage, Viewpoint.new(
        id: "VIEWPOINT-TECHNOLOGY_USAGE",
        name: "Technology Usage",
        allowed_element_types: Elements.core_elements,
        allowed_relationship_types: Relationships.classes
      )

      # Category:Cooperation Towards peer elements which cooperate with each
      # other. Typically across aspects.
      define :Business_process_cooperation, Viewpoint.new(
        id: "VIEWPOINT-BUSINESS_PROCESS_COOPERATION",
        name: "Business Process Cooperation",
        allowed_element_types: ConnectorType.values + [
          Elements::ApplicationService, Elements::BusinessActor,
          Elements::BusinessCollaboration, Elements::BusinessEvent,
          Elements::BusinessFunction, Elements::BusinessInteraction,
          Elements::BusinessObject, Elements::BusinessProcess,
          Elements::BusinessRole, Elements::BusinessService,
          Elements::Location, Elements::Representation
        ],
        allowed_relationship_types: Relationships.default
      )

      define :Application_cooperation, Viewpoint.new(
        id: "VIEWPOINT-APPLICATION_COOPERATION",
        name: "Application Cooperation",
        allowed_element_types: ConnectorType.values + [
          Elements::ApplicationCollaboration, Elements::ApplicationComponent,
          Elements::ApplicationFunction, Elements::ApplicationInteraction,
          Elements::ApplicationInterface, Elements::ApplicationService,
          Elements::DataObject, Elements::Location
        ],
        allowed_relationship_types: Relationships.default
      )

      # Category:Realization Viewpoints where you are looking at elements that
      # realize other elements. Typically from one layer and downwards to a
      # below layer.
      define :Service_realization, Viewpoint.new(
        id: "VIEWPOINT-SERVICE_REALIZATION",
        name: "Service Realization",
        allowed_element_types: ConnectorType.values + [
          Elements::ApplicationCollaboration, Elements::ApplicationComponent,
          Elements::ApplicationService, Elements::BusinessActor,
          Elements::BusinessCollaboration, Elements::BusinessEvent,
          Elements::BusinessFunction, Elements::BusinessInteraction,
          Elements::BusinessObject, Elements::BusinessProcess,
          Elements::BusinessRole, Elements::BusinessService,
          Elements::DataObject
        ],
        allowed_relationship_types: Relationships.default
      )

      define :Implementation_and_deployment, Viewpoint.new(
        id: "VIEWPOINT-IMPLEMENTATION_AND_DEPLOYMENT",
        name: "Implementation and Deployment",
        allowed_element_types: ConnectorType.values + [
          Elements::ApplicationCollaboration, Elements::ApplicationComponent,
          Elements::Artifact, Elements::CommunicationPath,
          Elements::DataObject, Elements::Device,
          Elements::InfrastructureService, Elements::Network, Elements::Node,
          Elements::SystemSoftware
        ],
        allowed_relationship_types: Relationships.default
      )

      define :Goal_realization, Viewpoint.new(
        id: "VIEWPOINT-GOAL_REALIZATION",
        name: "Goal Realization",
        allowed_element_types: [
          Elements::Constraint, Elements::Goal, Elements::Principle,
          Elements::Requirement
        ],
        allowed_relationship_types: [
          Relationships::Aggregation, Relationships::Association,
          Relationships::Composition, Relationships::Influence,
          Relationships::Realization, Relationships::Specialization
        ]
      )

      define :Goal_contribution, Viewpoint.new(
        id: "VIEWPOINT-GOAL_CONTRIBUTION",
        name: "Goal Contribution",
        allowed_element_types: [
          Elements::Constraint, Elements::Goal, Elements::Principle,
          Elements::Requirement
        ],
        allowed_relationship_types: [
          Relationships::Aggregation, Relationships::Association,
          Relationships::Composition, Relationships::Influence,
          Relationships::Realization, Relationships::Specialization
        ]
      )

      define :Principles, Viewpoint.new(
        id: "VIEWPOINT-PRINCIPLES",
        name: "Principles",
        allowed_element_types: [Elements::Goal, Elements::Principle],
        allowed_relationship_types: [
          Relationships::Aggregation, Relationships::Association,
          Relationships::Composition, Relationships::Influence,
          Relationships::Realization, Relationships::Specialization
        ]
      )

      define :Requirements_realization, Viewpoint.new(
        id: "VIEWPOINT-REQUIREMENTS_REALIZATION",
        name: "Requirements Realization",
        allowed_element_types: Elements.core_elements + ConnectorType.values + [
          Elements::Constraint, Elements::Goal, Elements::Requirement
        ],
        allowed_relationship_types: Relationships.default
      )

      define :Motivation, Viewpoint.new(
        id: "VIEWPOINT-MOTIVATION",
        name: "Motivation",
        allowed_element_types: [
          Elements::Assessment, Elements::Constraint, Elements::Driver,
          Elements::Goal, Elements::Principle, Elements::Requirement,
          Elements::Stakeholder
        ],
        allowed_relationship_types: [
          Relationships::Aggregation, Relationships::Association,
          Relationships::Composition, Relationships::Flow,
          Relationships::Influence, Relationships::Realization,
          Relationships::Specialization
        ]
      )

      # Strategy Viewpoints
      define :Strategy, Viewpoint.new(
        id: "VIEWPOINT-STRATEGY",
        name: "Strategy",
        allowed_element_types: Elements.core_elements,
        allowed_relationship_types: Relationships.classes
      )

      define :Capability_map, Viewpoint.new(
        id: "VIEWPOINT-CAPABILITY_MAP",
        name: "Capability Map",
        allowed_element_types: Elements.core_elements,
        allowed_relationship_types: Relationships.classes
      )

      define :Outcome_realization, Viewpoint.new(
        id: "VIEWPOINT-OUTCOME_REALIZATION",
        name: "Outcome Realization",
        allowed_element_types: Elements.core_elements,
        allowed_relationship_types: Relationships.classes
      )

      define :Resource_map, Viewpoint.new(
        id: "VIEWPOINT-RESOURCE_MAP",
        name: "Resource Map",
        allowed_element_types: Elements.core_elements,
        allowed_relationship_types: Relationships.classes
      )

      # Implementation and Migration Viewpoints
      define :Project, Viewpoint.new(
        id: "VIEWPOINT-PROJECT",
        name: "Project",
        allowed_element_types: ConnectorType.values + [
          Elements::BusinessActor, Elements::BusinessRole,
          Elements::Deliverable, Elements::Goal, Elements::WorkPackage
        ],
        allowed_relationship_types: Relationships.default - [Relationships::Access]
      )

      define :Migration, Viewpoint.new(
        id: "VIEWPOINT-MIGRATION",
        name: "Migration",
        allowed_element_types: ConnectorType.values + [Elements::Gap, Elements::Plateau],
        allowed_relationship_types: [
          Relationships::AndJunction, Relationships::Association,
          Relationships::Composition, Relationships::Flow,
          Relationships::AndJunction, Relationships::OrJunction,
          Relationships::Triggering
        ]
      )

      define :Implementation_and_migration, Viewpoint.new(
        id: "VIEWPOINT-IMPLEMENTATION_AND_MIGRATION",
        name: "Implementation and Migration",
        allowed_element_types: Elements.core_elements + ConnectorType.values + [
          Elements::Location, Elements::Requirement, Elements::Constraint,
          Elements::Goal, Elements::BusinessRole, Elements::WorkPackage,
          Elements::Deliverable, Elements::BusinessActor, Elements::Plateau,
          Elements::Gap
        ],
        allowed_relationship_types: Relationships.default
      )

      # Other Viewpoints
      define :Stakeholder, Viewpoint.new(
        id: "VIEWPOINT-STAKEHOLDER",
        name: "Stakeholder",
        allowed_element_types: [
          Elements::Assessment, Elements::Driver, Elements::Goal,
          Elements::Stakeholder
        ],
        allowed_relationship_types: [
          Relationships::Aggregation, Relationships::Association,
          Relationships::Composition, Relationships::Influence,
          Relationships::Specialization
        ]
      )

      # Other older viewpoints
      define :Actor_cooperation, Viewpoint.new(
        id: "VIEWPOINT-ACTOR_COOPERATION",
        name: "Actor Co-operation",
        allowed_element_types: ConnectorType.values + [
          Elements::ApplicationComponent, Elements::ApplicationInterface,
          Elements::ApplicationService, Elements::BusinessActor,
          Elements::BusinessCollaboration, Elements::BusinessInterface,
          Elements::BusinessRole, Elements::BusinessService
        ],
        allowed_relationship_types: Relationships.default - [Relationships::Access]
      )

      define :Business_function, Viewpoint.new(
        id: "VIEWPOINT-BUSINESS_FUNCTION",
        name: "Business Function",
        allowed_element_types: ConnectorType.values + [
          Elements::BusinessActor, Elements::BusinessFunction,
          Elements::BusinessRole
        ],
        allowed_relationship_types: Relationships.default - [Relationships::Access, Relationships::Realization]
      )

      define :Business_process, Viewpoint.new(
        id: "VIEWPOINT-BUSINESS_PROCESS",
        name: "Business Process",
        allowed_element_types: ConnectorType.values + [
          Elements::ApplicationService, Elements::BusinessActor,
          Elements::BusinessCollaboration, Elements::BusinessEvent,
          Elements::BusinessFunction, Elements::BusinessInteraction,
          Elements::BusinessObject, Elements::BusinessProcess,
          Elements::BusinessRole, Elements::BusinessService,
          Elements::Location, Elements::Representation
        ],
        allowed_relationship_types: Relationships.default
      )

      define :Application_behavior, Viewpoint.new(
        id: "VIEWPOINT-APPLICATION_BEHAVIOR",
        name: "Application Behavior",
        allowed_element_types: ConnectorType.values + [
          Elements::ApplicationCollaboration, Elements::ApplicationComponent,
          Elements::ApplicationFunction, Elements::ApplicationInteraction,
          Elements::ApplicationInterface, Elements::ApplicationService,
          Elements::DataObject
        ],
        allowed_relationship_types: Relationships.default
      )

      define :Application_structure, Viewpoint.new(
        id: "VIEWPOINT-APPLICATION_STRUCTURE",
        name: "Application Structure",
        allowed_element_types: ConnectorType.values + [
          Elements::ApplicationCollaboration, Elements::ApplicationComponent,
          Elements::ApplicationInterface, Elements::DataObject
        ],
        allowed_relationship_types: Relationships.default - [Relationships::Realization]
      )

      define :Infrastructure, Viewpoint.new(
        id: "VIEWPOINT-INFRASTRUCTURE",
        name: "Infrastructure",
        allowed_element_types: ConnectorType.values + [
          Elements::Artifact, Elements::CommunicationPath, Elements::Device,
          Elements::InfrastructureFunction, Elements::InfrastructureInterface,
          Elements::InfrastructureService, Elements::Location,
          Elements::Network, Elements::Node, Elements::SystemSoftware
        ],
        allowed_relationship_types: Relationships.default
      )

      define :Infrastructure_usage, Viewpoint.new(
        id: "VIEWPOINT-INFRASTRUCTURE_USAGE",
        name: "Infrastructure Usage",
        allowed_element_types: ConnectorType.values + [
          Elements::ApplicationComponent, Elements::ApplicationFunction,
          Elements::CommunicationPath, Elements::Device,
          Elements::InfrastructureFunction, Elements::InfrastructureInterface,
          Elements::InfrastructureService, Elements::Network, Elements::Node,
          Elements::SystemSoftware
        ],
        allowed_relationship_types: Relationships.default
      )

      define :Landscape_map, Viewpoint.new(
        id: "VIEWPOINT-LANDSCAPE_MAP",
        name: "Landscape Map",
        allowed_element_types: Elements.classes + ConnectorType.values,
        allowed_relationship_types: Relationships.classes
      )

      def self.[](idx)
        values[idx]
      end

      def self.with_name(name)
        values.find { |vp| vp.name == name }
      end

      VIEWPOINT_CONTENT_ENUM = %w[Details Coherence Overview].freeze

      VIEWPOINT_PURPOSE_ENUM = %w[Designing Deciding Informing].freeze
    end
  end
end
