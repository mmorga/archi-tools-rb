# frozen_string_literal: true

module Archimate
  module DataModel
    module Viewpoints
      # Basic Viewpoints
      INTRODUCTORY = Viewpoint.new(
        id: "VIEWPOINT-INTRODUCTORY",
        name: "Introductory",
        allowed_element_types: Elements.core_elements,
        allowed_relationship_types: Relationships.classes
      )

      # Category:Composition Viewpoints that defines internal compositions and aggregations of elements.
      ORGANIZATION = Viewpoint.new(
        id: "VIEWPOINT-ORGANIZATION",
        name: "Organization",
        allowed_element_types: ConnectorType.values + [
          Elements::BusinessActor, Elements::BusinessCollaboration,
          Elements::BusinessInterface, Elements::BusinessRole,
          Elements::Location
        ],
        allowed_relationship_types: Relationships.default - [Relationships::Access, Relationships::Realization]
      )

      APPLICATION_PLATFORM = Viewpoint.new(
        id: "VIEWPOINT-APPLICATION_PLATFORM",
        name: "Application Platform",
        allowed_element_types: Elements.core_elements,
        allowed_relationship_types: Relationships.classes
      )

      INFORMATION_STRUCTURE = Viewpoint.new(
        id: "VIEWPOINT-INFORMATION_STRUCTURE",
        name: "Information Structure",
        allowed_element_types: ConnectorType.values + [
          Elements::Artifact, Elements::BusinessObject, Elements::DataObject,
          Elements::Meaning, Elements::Representation
        ],
        allowed_relationship_types: Relationships.default - [Relationships::Assignment, Relationships::Serving]
      )

      TECHNOLOGY = Viewpoint.new(
        id: "VIEWPOINT-TECHNOLOGY",
        name: "Technology",
        allowed_element_types: Elements.core_elements,
        allowed_relationship_types: Relationships.classes
      )

      LAYERED = Viewpoint.new(
        id: "VIEWPOINT-LAYERED",
        name: "Layered",
        allowed_element_types: Elements.classes + ConnectorType.values,
        allowed_relationship_types: Relationships.classes
      )

      PHYSICAL = Viewpoint.new(
        id: "VIEWPOINT-PHYSICAL",
        name: "Physical",
        allowed_element_types: Elements.core_elements,
        allowed_relationship_types: Relationships.classes
      )

      # Category:Support Viewpoints where you are looking at elements that are
      # supported by other elements. Typically from one layer and upwards to an
      # above layer.
      PRODUCT = Viewpoint.new(
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

      APPLICATION_USAGE = Viewpoint.new(
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

      TECHNOLOGY_USAGE = Viewpoint.new(
        id: "VIEWPOINT-TECHNOLOGY_USAGE",
        name: "Technology Usage",
        allowed_element_types: Elements.core_elements,
        allowed_relationship_types: Relationships.classes
      )

      # Category:Cooperation Towards peer elements which cooperate with each
      # other. Typically across aspects.
      BUSINESS_PROCESS_COOPERATION = Viewpoint.new(
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

      APPLICATION_COOPERATION = Viewpoint.new(
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
      SERVICE_REALIZATION = Viewpoint.new(
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

      IMPLEMENTATION_AND_DEPLOYMENT = Viewpoint.new(
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

      GOAL_REALIZATION = Viewpoint.new(
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

      GOAL_CONTRIBUTION = Viewpoint.new(
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

      PRINCIPLES = Viewpoint.new(
        id: "VIEWPOINT-PRINCIPLES",
        name: "Principles",
        allowed_element_types: [Elements::Goal, Elements::Principle],
        allowed_relationship_types: [
          Relationships::Aggregation, Relationships::Association,
          Relationships::Composition, Relationships::Influence,
          Relationships::Realization, Relationships::Specialization
        ]
      )

      REQUIREMENTS_REALIZATION = Viewpoint.new(
        id: "VIEWPOINT-REQUIREMENTS_REALIZATION",
        name: "Requirements Realization",
        allowed_element_types: Elements.core_elements + ConnectorType.values + [
          Elements::Constraint, Elements::Goal, Elements::Requirement
        ],
        allowed_relationship_types: Relationships.default
      )

      MOTIVATION = Viewpoint.new(
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
      STRATEGY = Viewpoint.new(
        id: "VIEWPOINT-STRATEGY",
        name: "Strategy",
        allowed_element_types: Elements.core_elements,
        allowed_relationship_types: Relationships.classes
      )

      CAPABILITY_MAP = Viewpoint.new(
        id: "VIEWPOINT-CAPABILITY_MAP",
        name: "Capability Map",
        allowed_element_types: Elements.core_elements,
        allowed_relationship_types: Relationships.classes
      )

      OUTCOME_REALIZATION = Viewpoint.new(
        id: "VIEWPOINT-OUTCOME_REALIZATION",
        name: "Outcome Realization",
        allowed_element_types: Elements.core_elements,
        allowed_relationship_types: Relationships.classes
      )

      RESOURCE_MAP = Viewpoint.new(
        id: "VIEWPOINT-RESOURCE_MAP",
        name: "Resource Map",
        allowed_element_types: Elements.core_elements,
        allowed_relationship_types: Relationships.classes
      )

      # Implementation and Migration Viewpoints
      PROJECT = Viewpoint.new(
        id: "VIEWPOINT-PROJECT",
        name: "Project",
        allowed_element_types: ConnectorType.values + [
          Elements::BusinessActor, Elements::BusinessRole,
          Elements::Deliverable, Elements::Goal, Elements::WorkPackage
        ],
        allowed_relationship_types: Relationships.default - [Relationships::Access]
      )

      MIGRATION = Viewpoint.new(
        id: "VIEWPOINT-MIGRATION",
        name: "Migration",
        allowed_element_types: ConnectorType.values + [Elements::Gap, Elements::Plateau],
        allowed_relationship_types: [
          Relationships::AndJunction, Relationships::Association,
          Relationships::Composition, Relationships::Flow,
          Relationships::Junction, Relationships::OrJunction,
          Relationships::Triggering
        ]
      )

      IMPLEMENTATION_AND_MIGRATION = Viewpoint.new(
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
      STAKEHOLDER = Viewpoint.new(
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
      ACTOR_COOPERATION = Viewpoint.new(
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

      BUSINESS_FUNCTION = Viewpoint.new(
        id: "VIEWPOINT-BUSINESS_FUNCTION",
        name: "Business Function",
        allowed_element_types: ConnectorType.values + [
          Elements::BusinessActor, Elements::BusinessFunction,
          Elements::BusinessRole
        ],
        allowed_relationship_types: Relationships.default - [Relationships::Access, Relationships::Realization]
      )

      BUSINESS_PROCESS = Viewpoint.new(
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

      APPLICATION_BEHAVIOR = Viewpoint.new(
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

      APPLICATION_STRUCTURE = Viewpoint.new(
        id: "VIEWPOINT-APPLICATION_STRUCTURE",
        name: "Application Structure",
        allowed_element_types: ConnectorType.values + [
          Elements::ApplicationCollaboration, Elements::ApplicationComponent,
          Elements::ApplicationInterface, Elements::DataObject
        ],
        allowed_relationship_types: Relationships.default - [Relationships::Realization]
      )

      INFRASTRUCTURE = Viewpoint.new(
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

      INFRASTRUCTURE_USAGE = Viewpoint.new(
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

      LANDSCAPE_MAP = Viewpoint.new(
        id: "VIEWPOINT-LANDSCAPE_MAP",
        name: "Landscape Map",
        allowed_element_types: Elements.classes + ConnectorType.values,
        allowed_relationship_types: Relationships.classes
      )

      def self.with_name(name)
        constants.map { |sym| const_get(sym) }.find { |vp| vp.name == name }
      end
    end
  end
end
