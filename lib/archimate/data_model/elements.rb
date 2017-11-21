# frozen_string_literal: true

module Archimate
  module DataModel
    module Elements
      #############################################################
      # Business Layer
      #############################################################

      class BusinessActor < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class BusinessCollaboration < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class BusinessEvent < Element
        CLASSIFICATION = :behavioral
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class BusinessFunction < Element
        CLASSIFICATION = :behavioral
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class BusinessInteraction < Element
        CLASSIFICATION = :behavioral
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class BusinessInterface < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class BusinessObject < Element
        CLASSIFICATION = :passive_structure
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class BusinessProcess < Element
        CLASSIFICATION = :behavioral
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class BusinessRole < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class BusinessService < Element
        CLASSIFICATION = :behavioral
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class Contract < Element
        CLASSIFICATION = :passive_structure
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class Location < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class Product < Element
        CLASSIFICATION = :passive_structure
        LAYER = Layers::Business

        def initialize(args)
          super
        end
      end

      class Representation < Element
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
        CLASSIFICATION = :active_structure
        LAYER = Layers::Application

        def initialize(args)
          super
        end
      end

      class ApplicationComponent < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Application

        def initialize(args)
          super
        end
      end

      class ApplicationEvent < Element
        CLASSIFICATION = :behavioral
        LAYER = Layers::Application

        def initialize(args)
          super
        end
      end

      class ApplicationFunction < Element
        CLASSIFICATION = :behavioral
        LAYER = Layers::Application

        def initialize(args)
          super
        end
      end

      class ApplicationInteraction < Element
        CLASSIFICATION = :behavioral
        LAYER = Layers::Application

        def initialize(args)
          super
        end
      end

      class ApplicationInterface < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Application

        def initialize(args)
          super
        end
      end

      class ApplicationProcess < Element
        CLASSIFICATION = :behavioral
        LAYER = Layers::Application

        def initialize(args)
          super
        end
      end

      class ApplicationService < Element
        CLASSIFICATION = :behavioral
        LAYER = Layers::Application

        def initialize(args)
          super
        end
      end

      class DataObject < Element
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
        CLASSIFICATION = :passive_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class CommunicationNetwork < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class CommunicationPath < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class Device < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class InfrastructureFunction < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class InfrastructureInterface < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class InfrastructureService < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class Network < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class Node < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class Path < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class SystemSoftware < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class TechnologyCollaboration < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class TechnologyEvent < Element
        CLASSIFICATION = :behavioral
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class TechnologyFunction < Element
        CLASSIFICATION = :behavioral
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class TechnologyInteraction < Element
        CLASSIFICATION = :behavioral
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class TechnologyInterface < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class TechnologyObject < Element
        CLASSIFICATION = :passive_structure
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class TechnologyProcess < Element
        CLASSIFICATION = :behavioral
        LAYER = Layers::Technology

        def initialize(args)
          super
        end
      end

      class TechnologyService < Element
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
        CLASSIFICATION = :active_structure
        LAYER = Layers::Physical

        def initialize(args)
          super
        end
      end

      class Equipment < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Physical

        def initialize(args)
          super
        end
      end

      class Facility < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Physical

        def initialize(args)
          super
        end
      end

      class Material < Element
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
        CLASSIFICATION = :active_structure
        LAYER = Layers::Motivation

        def initialize(args)
          super
        end
      end

      class Constraint < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Motivation

        def initialize(args)
          super
        end
      end

      class Driver < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Motivation

        def initialize(args)
          super
        end
      end

      class Goal < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Motivation

        def initialize(args)
          super
        end
      end

      class Meaning < Element
        CLASSIFICATION = :passive_structure
        LAYER = Layers::Motivation

        def initialize(args)
          super
        end
      end

      class Outcome < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Motivation

        def initialize(args)
          super
        end
      end

      class Principle < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Motivation

        def initialize(args)
          super
        end
      end

      class Requirement < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Motivation

        def initialize(args)
          super
        end
      end

      class Stakeholder < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Motivation

        def initialize(args)
          super
        end
      end

      class Value < Element
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
        CLASSIFICATION = :passive_structure
        LAYER = Layers::Implementation_and_migration

        def initialize(args)
          super
        end
      end

      class Gap < Element
        CLASSIFICATION = :passive_structure
        LAYER = Layers::Implementation_and_migration

        def initialize(args)
          super
        end
      end

      class ImplementationEvent < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Implementation_and_migration

        def initialize(args)
          super
        end
      end

      class Plateau < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Implementation_and_migration

        def initialize(args)
          super
        end
      end

      class WorkPackage < Element
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
        CLASSIFICATION = :active_structure
        LAYER = Layers::Connectors

        def initialize(args)
          super
        end
      end

      class Junction < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Connectors

        def initialize(args)
          super
        end
      end

      class OrJunction < Element
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
        CLASSIFICATION = :active_structure
        LAYER = Layers::Strategy

        def initialize(args)
          super
        end
      end

      class CourseOfAction < Element
        CLASSIFICATION = :active_structure
        LAYER = Layers::Strategy

        def initialize(args)
          super
        end
      end

      class Resource < Element
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
