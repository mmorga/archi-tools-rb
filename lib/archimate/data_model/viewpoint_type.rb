# frozen_string_literal: true

require "ruby-enum"

module Archimate
  module DataModel
    class ViewpointType
      include Ruby::Enum

      # Basic Viewpoints
      define :Introductory, Viewpoints::INTRODUCTORY

      # Category:Composition Viewpoints that defines internal compositions and aggregations of elements.
      define :Organization, Viewpoints::ORGANIZATION

      define :Application_platform, Viewpoints::APPLICATION_PLATFORM

      define :Information_structure, Viewpoints::INFORMATION_STRUCTURE

      define :Technology, Viewpoints::TECHNOLOGY

      define :Layered, Viewpoints::LAYERED

      define :Physical, Viewpoints::PHYSICAL

      # Category:Support Viewpoints where you are looking at elements that are
      # supported by other elements. Typically from one layer and upwards to an
      # above layer.
      define :Product, Viewpoints::PRODUCT

      define :Application_usage, Viewpoints::APPLICATION_USAGE

      define :Technology_usage, Viewpoints::TECHNOLOGY_USAGE

      # Category:Cooperation Towards peer elements which cooperate with each
      # other. Typically across aspects.
      define :Business_process_cooperation, Viewpoints::BUSINESS_PROCESS_COOPERATION

      define :Application_cooperation, Viewpoints::APPLICATION_COOPERATION

      # Category:Realization Viewpoints where you are looking at elements that
      # realize other elements. Typically from one layer and downwards to a
      # below layer.
      define :Service_realization, Viewpoints::SERVICE_REALIZATION

      define :Implementation_and_deployment, Viewpoints::IMPLEMENTATION_AND_DEPLOYMENT

      define :Goal_realization, Viewpoints::GOAL_REALIZATION

      define :Goal_contribution, Viewpoints::GOAL_CONTRIBUTION

      define :Principles, Viewpoints::PRINCIPLES

      define :Requirements_realization, Viewpoints::REQUIREMENTS_REALIZATION

      define :Motivation, Viewpoints::MOTIVATION

      # Strategy Viewpoints
      define :Strategy, Viewpoints::STRATEGY

      define :Capability_map, Viewpoints::CAPABILITY_MAP

      define :Outcome_realization, Viewpoints::OUTCOME_REALIZATION

      define :Resource_map, Viewpoints::RESOURCE_MAP

      # Implementation and Migration Viewpoints
      define :Project, Viewpoints::PROJECT

      define :Migration, Viewpoints::MIGRATION

      define :Implementation_and_migration, Viewpoints::IMPLEMENTATION_AND_MIGRATION

      # Other Viewpoints
      define :Stakeholder, Viewpoints::STAKEHOLDER

      # Other older viewpoints
      define :Actor_cooperation, Viewpoints::ACTOR_COOPERATION

      define :Business_function, Viewpoints::BUSINESS_FUNCTION

      define :Business_process, Viewpoints::BUSINESS_PROCESS

      define :Application_behavior, Viewpoints::APPLICATION_BEHAVIOR

      define :Application_structure, Viewpoints::APPLICATION_STRUCTURE

      define :Infrastructure, Viewpoints::INFRASTRUCTURE

      define :Infrastructure_usage, Viewpoints::INFRASTRUCTURE_USAGE

      define :Landscape_map, Viewpoints::LANDSCAPE_MAP

      def self.[](idx)
        values[idx]
      end
    end

    VIEWPOINT_CONTENT_ENUM = %w[Details Coherence Overview].freeze

    VIEWPOINT_PURPOSE_ENUM = %w[Designing Deciding Informing].freeze
  end
end
