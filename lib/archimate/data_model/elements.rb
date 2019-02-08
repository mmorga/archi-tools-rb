# frozen_string_literal: true

module Archimate
  module DataModel
    module Elements
      #############################################################
      # Business Layer
      #############################################################

      class BusinessActor < Element
        NAME = "Business Actor"
        DESCRIPTION = "A business actor is a business entity that is capable of performing behavior."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class BusinessCollaboration < Element
        NAME = "Business Collaboration"
        DESCRIPTION = "A business collaboration is an aggregate of two or more business internal active structure elements that work together to perform collective behavior."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class BusinessEvent < Element
        NAME = "Business Event"
        DESCRIPTION = "A business event is a business behavior element that denotes an organizational state change. It may originate from and be resolved inside or outside the organization."
        CLASSIFICATION = :behavioral
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class BusinessFunction < Element
        NAME = "Business Function"
        DESCRIPTION = "A business function is a collection of business behavior based on a chosen set of criteria (typically required business resources and/or competencies), closely aligned to an organization, but not necessarily explicitly governed by the organization."
        CLASSIFICATION = :behavioral
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class BusinessInteraction < Element
        NAME = "Business Interaction"
        DESCRIPTION = "A business interaction is a unit of collective business behavior performed by (a collaboration of) two or more business roles."
        CLASSIFICATION = :behavioral
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class BusinessInterface < Element
        NAME = "Business Interface"
        DESCRIPTION = "A business interface is a point of access where a business service is made available to the environment."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class BusinessObject < Element
        NAME = "Business Object"
        DESCRIPTION = "A business object represents a concept used within a particular business domain."
        CLASSIFICATION = :passive_structure
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class BusinessProcess < Element
        NAME = "Business Process"
        DESCRIPTION = "A business process represents a sequence of business behaviors that achieves a specific outcome such as a defined set of products or business services."
        CLASSIFICATION = :behavioral
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class BusinessRole < Element
        NAME = "Business Role"
        DESCRIPTION = "A business role is the responsibility for performing specific behavior, to which an actor can be assigned, or the part an actor plays in a particular action or event."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class BusinessService < Element
        NAME = "Business Service"
        DESCRIPTION = "A business service represents an explicitly defined exposed business behavior."
        CLASSIFICATION = :behavioral
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class Contract < Element
        NAME = "Contract"
        DESCRIPTION = "A contract represents a formal or informal specification of an agreement between a provider and a consumer that specifies the rights and obligations associated with a product and establishes functional and non-functional parameters for interaction."
        CLASSIFICATION = :passive_structure
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class Location < Element
        NAME = "Location"
        DESCRIPTION = "A location is a place or position where structure elements can be located or behavior can be performed."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class Product < Element
        NAME = "Product"
        DESCRIPTION = "A product represents a coherent collection of services and/or passive structure elements, accompanied by a contract/set of agreements, which is offered as a whole to (internal or external) customers."
        CLASSIFICATION = :passive_structure
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class Representation < Element
        NAME = "Representation"
        DESCRIPTION = "A representation represents a perceptible form of the information carried by a business object."
        CLASSIFICATION = :passive_structure
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      #############################################################
      # Application Layer
      #############################################################

      class ApplicationCollaboration < Element
        NAME = "Application Collaboration"
        DESCRIPTION = "An application collaboration represents an aggregate of two or more application components that work together to perform collective application behavior."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Application

        def initialize(args)
          super
        end
      end

      class ApplicationComponent < Element
        NAME = "Application Component"
        DESCRIPTION = "An application component represents an encapsulation of application functionality aligned to implementation structure, which is modular and replaceable. It encapsulates its behavior and data, exposes services, and makes them available through interfaces."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Application

        def initialize(args)
          super
        end
      end

      class ApplicationEvent < Element
        NAME = "Application Event"
        DESCRIPTION = "An application event is an application behavior element that denotes a state change."
        CLASSIFICATION = :behavioral
        LAYER = Layers::Application

        def initialize(args)
          super
        end
      end

      class ApplicationFunction < Element
        NAME = "Application Function"
        DESCRIPTION = "An application function represents automated behavior that can be performed by an application component."
        CLASSIFICATION = :behavioral
        LAYER = Layers::Application

        def initialize(args)
          super
        end
      end

      class ApplicationInteraction < Element
        NAME = "Application Interaction"
        DESCRIPTION = "An application interaction represents a unit of collective application behavior performed by (a collaboration of) two or more application components."
        CLASSIFICATION = :behavioral
        LAYER = Layers::Application

        def initialize(args)
          super
        end
      end

      class ApplicationInterface < Element
        NAME = "Application Interface"
        DESCRIPTION = "An application interface represents a point of access where application services are made available to a user, another application component, or a node."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Application

        def initialize(args)
          super
        end
      end

      class ApplicationProcess < Element
        NAME = "Application Process"
        DESCRIPTION = "An application process represents a sequence of application behaviors that achieves a specific outcome."
        CLASSIFICATION = :behavioral
        LAYER = Layers::Application

        def initialize(args)
          super
        end
      end

      class ApplicationService < Element
        NAME = "Application Service"
        DESCRIPTION = "An application service represents an explicitly defined exposed application behavior."
        CLASSIFICATION = :behavioral
        LAYER = Layers::Application

        def initialize(args)
          super
        end
      end

      class DataObject < Element
        NAME = "Data Object"
        DESCRIPTION = "A data object represents data structured for automated processing."
        CLASSIFICATION = :passive_structure
        LAYER = Layers::Application

        def initialize(args)
          super
        end
      end

      #############################################################
      # Technology Layer
      #############################################################

      class Artifact < Element
        NAME = "Artifact"
        DESCRIPTION = "An artifact represents a piece of data that is used or produced in a software development process, or by deployment and operation of an IT system."
        CLASSIFICATION = :passive_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class CommunicationNetwork < Element
        NAME = "Communication Network"
        DESCRIPTION = "A communication network represents a set of structures that connects computer systems or other electronic devices for transmission, routing, and reception of data or data-based communications such as voice and video."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class CommunicationPath < Element
        NAME = "Communication Path"
        DESCRIPTION = "A path represents a link between two or more nodes, through which these nodes can exchange data or material."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class Device < Element
        NAME = "Device"
        DESCRIPTION = "A device is a physical IT resource upon which system software and artifacts may be stored or deployed for execution."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class InfrastructureFunction < Element
        NAME = "Infrastructure Function"
        DESCRIPTION = "A technology function represents a collection of technology behavior that can be performed by a node."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class InfrastructureInterface < Element
        NAME = "Infrastructure Interface"
        DESCRIPTION = "A technology interface represents a point of access where technology services offered by a node can be accessed."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class InfrastructureService < Element
        NAME = "Infrastructure Service"
        DESCRIPTION = "A technology service represents an explicitly defined exposed technology behavior."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class Network < Element
        NAME = "Network"
        DESCRIPTION = "A communication network represents a set of structures that connects computer systems or other electronic devices for transmission, routing, and reception of data or data-based communications such as voice and video."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class Node < Element
        NAME = "Node"
        DESCRIPTION = "A node represents a computational or physical resource that hosts, manipulates, or interacts with other computational or physical resources."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class Path < Element
        NAME = "Path"
        DESCRIPTION = "A path represents a link between two or more nodes, through which these nodes can exchange data or material."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class SystemSoftware < Element
        NAME = "System Software"
        DESCRIPTION = "System software represents software that provides or contributes to an environment for storing, executing, and using software or data deployed within it."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class TechnologyCollaboration < Element
        NAME = "Technology Collaboration"
        DESCRIPTION = "A technology collaboration represents an aggregate of two or more nodes that work together to perform collective technology behavior."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class TechnologyEvent < Element
        NAME = "Technology Event"
        DESCRIPTION = "A technology event is a technology behavior element that denotes a state change."
        CLASSIFICATION = :behavioral
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class TechnologyFunction < Element
        NAME = "Technology Function"
        DESCRIPTION = "A technology function represents a collection of technology behavior that can be performed by a node."
        CLASSIFICATION = :behavioral
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class TechnologyInteraction < Element
        NAME = "Technology Interaction"
        DESCRIPTION = "A technology interaction represents a unit of collective technology behavior performed by (a collaboration of) two or more nodes."
        CLASSIFICATION = :behavioral
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class TechnologyInterface < Element
        NAME = "Technology Interface"
        DESCRIPTION = "A technology interface represents a point of access where technology services offered by a node can be accessed."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class TechnologyObject < Element
        NAME = "Technology Object"
        DESCRIPTION = "A technology object represents a passive element that is used or produced by technology behavior."
        CLASSIFICATION = :passive_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class TechnologyProcess < Element
        NAME = "Technology Process"
        DESCRIPTION = "A technology process represents a sequence of technology behaviors that achieves a specific outcome."
        CLASSIFICATION = :behavioral
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class TechnologyService < Element
        NAME = "Technology Service"
        DESCRIPTION = "A technology service represents an explicitly defined exposed technology behavior."
        CLASSIFICATION = :behavioral
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      #############################################################
      # Physical Layer
      #############################################################

      class DistributionNetwork < Element
        NAME = "Distribution Network"
        DESCRIPTION = "A distribution network represents a physical network used to transport materials or energy."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Physical

        def initialize(args)
          super
        end
      end

      class Equipment < Element
        NAME = "Equipment"
        DESCRIPTION = "Equipment represents one or more physical machines, tools, or instruments that can create, use, store, move, or transform materials."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Physical

        def initialize(args)
          super
        end
      end

      class Facility < Element
        NAME = "Facility"
        DESCRIPTION = "A facility represents a physical structure or environment."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Physical

        def initialize(args)
          super
        end
      end

      class Material < Element
        NAME = "Material"
        DESCRIPTION = "Material represents tangible physical matter or physical elements."
        CLASSIFICATION = :passive_structure
        LAYER = Layers::Physical

        def initialize(args)
          super
        end
      end

      #############################################################
      # Motivation Layer
      #############################################################

      class Assessment < Element
        NAME = "Assessment"
        DESCRIPTION = "An assessment represents the result of an analysis of the state of affairs of the enterprise with respect to some driver."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Motivation

        def initialize(args)
          super
        end
      end

      class Constraint < Element
        NAME = "Constraint"
        DESCRIPTION = "A constraint represents a factor that prevents or obstructs the realization of goals."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Motivation

        def initialize(args)
          super
        end
      end

      class Driver < Element
        NAME = "Driver"
        DESCRIPTION = "A driver represents an external or internal condition that motivates an organization to define its goals and implement the changes necessary to achieve them."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Motivation

        def initialize(args)
          super
        end
      end

      class Goal < Element
        NAME = "Goal"
        DESCRIPTION = "A goal represents a high-level statement of intent, direction, or desired end state for an organization and its stakeholders."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Motivation

        def initialize(args)
          super
        end
      end

      class Meaning < Element
        NAME = "Meaning"
        DESCRIPTION = "Meaning represents the knowledge or expertise present in, or the interpretation given to, a core element in a particular context."
        CLASSIFICATION = :passive_structure
        LAYER = Layers::Motivation

        def initialize(args)
          super
        end
      end

      class Outcome < Element
        NAME = "Outcome"
        DESCRIPTION = "An outcome represents an end result that has been achieved."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Motivation

        def initialize(args)
          super
        end
      end

      class Principle < Element
        NAME = "Principle"
        DESCRIPTION = "A principle represents a qualitative statement of intent that should be met by the architecture."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Motivation

        def initialize(args)
          super
        end
      end

      class Requirement < Element
        NAME = "Requirement"
        DESCRIPTION = "A requirement represents a statement of need that must be met by the architecture."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Motivation

        def initialize(args)
          super
        end
      end

      class Stakeholder < Element
        NAME = "Stakeholder"
        DESCRIPTION = "A stakeholder is the role of an individual, team, or organization (or classes thereof) that represents their interests in the outcome of the architecture."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Motivation

        def initialize(args)
          super
        end
      end

      class Value < Element
        NAME = "Value"
        DESCRIPTION = "Value represents the relative worth, utility, or importance of a core element or an outcome."
        CLASSIFICATION = :passive_structure
        LAYER = Layers::Motivation

        def initialize(args)
          super
        end
      end

      #############################################################
      # Implementation and Migration Layer
      #############################################################

      class Deliverable < Element
        NAME = "Deliverable"
        DESCRIPTION = "A deliverable represents a precisely-defined outcome of a work package."
        CLASSIFICATION = :passive_structure
        LAYER = Layers::Implementation_and_migration

        def initialize(args)
          super
        end
      end

      class Gap < Element
        NAME = "Gap"
        DESCRIPTION = "A gap represents a statement of difference between two plateaus."
        CLASSIFICATION = :passive_structure
        LAYER = Layers::Implementation_and_migration

        def initialize(args)
          super
        end
      end

      class ImplementationEvent < Element
        NAME = "Implementation Event"
        DESCRIPTION = "An implementation event is a behavior element that denotes a state change related to implementation or migration."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Implementation_and_migration

        def initialize(args)
          super
        end
      end

      class Plateau < Element
        NAME = "Plateau"
        DESCRIPTION = "A plateau represents a relatively stable state of the architecture that exists during a limited period of time."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Implementation_and_migration

        def initialize(args)
          super
        end
      end

      class WorkPackage < Element
        NAME = "Work Package"
        DESCRIPTION = "A work package represents a series of actions identified and designed to achieve specific results within specified time and resource constraints."
        CLASSIFICATION = :behavioral
        LAYER = Layers::Implementation_and_migration

        def initialize(args)
          super
        end
      end

      #############################################################
      # Connectors Pseudo Layer
      #############################################################

      class AndJunction < Element
        NAME = "And Junction"
        DESCRIPTION = "A junction is used to connect relationships of the same type."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Connectors

        def initialize(args)
          super
        end
      end

      class OrJunction < Element
        NAME = "Or Junction"
        DESCRIPTION = "A junction is used to connect relationships of the same type."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Connectors

        def initialize(args)
          super
        end
      end

      #############################################################
      # Strategy Layer
      #############################################################

      class Capability < Element
        NAME = "Capability"
        DESCRIPTION = "A capability represents an ability that an active structure element, such as an organization, person, or system, possesses."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Strategy

        def initialize(args)
          super
        end
      end

      class CourseOfAction < Element
        NAME = "Course Of Action"
        DESCRIPTION = "A course of action is an approach or plan for configuring some capabilities and resources of the enterprise, undertaken to achieve a goal."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Strategy

        def initialize(args)
          super
        end
      end

      class Resource < Element
        NAME = "Resource"
        DESCRIPTION = "A resource represents an asset owned or controlled by an individual or organization."
        CLASSIFICATION = :active_structure
        LAYER = Layers::Strategy

        def initialize(args)
          super
        end
      end

      #############################################################
      # Other Layer
      #############################################################

      class Grouping < Element
        NAME = "Grouping"
        DESCRIPTION = "The grouping element aggregates or composes concepts that belong together based on some common characteristic."
        CLASSIFICATION = :other
        LAYER = Layers::Other

        def initialize(args)
          super
        end
      end

      #############################################################
      # Module Methods
      #############################################################

      def self.create(*args)
        cls_name = str_filter(args[0].delete(:type))
        const_get(cls_name).new(*args)
      rescue NameError => err
        Archimate::Logging.error "An invalid element type '#{cls_name}' was used to create an Element"
        raise err
      end

      def self.===(other)
        constants.map(&:to_s).include?(str_filter(other))
      end

      def self.str_filter(str)
        element_substitutions = {}.freeze
        cls_name = str.strip
        element_substitutions.fetch(cls_name, cls_name)
      end

      def self.classes
        constants.map { |cls_name| const_get(cls_name) }
      end

      def self.core_elements
        classes.select do |el|
          [Layers::Business, Layers::Application, Layers::Technology].include?(el::LAYER)
        end
      end
    end
  end
end
