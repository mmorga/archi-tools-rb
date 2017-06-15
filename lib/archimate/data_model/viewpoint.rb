# frozen_string_literal: true

module Archimate
  module DataModel
    # Basic Viewpoints
    # Category:Composition Viewpoints that defines internal compositions and aggregations of elements.
    COMPOSITION_VIEWPOINTS = [
      "Organization",
      "Application Platform",
      "Information Structure",
      "Technology",
      "Layered",
      "Physical"
    ].freeze

    # Category:Support Viewpoints where you are looking at elements that are supported by other elements. Typically from one layer and upwards to an above layer.
    SUPPORT_VIEWPOINTS = [
      "Product",
      "Application Usage",
      "Technology Usage"
    ].freeze

    # Category:Cooperation Towards peer elements which cooperate with each other. Typically across aspects.
    COOPERATION_VIEWPOINTS = [
      "Business Process Cooperation",
      "Application Cooperation"
    ].freeze

    # Category:Realization Viewpoints where you are looking at elements that realize other elements. Typically from one layer and downwards to a below layer.
    REALIZATION_VIEWPOINTS = [
      "Service Realization",
      "Implementation and Deployment",
      "Goal Realization",
      "Goal Contribution",
      "Principles",
      "Requirements Realization",
      "Motivation"
    ].freeze

    # Strategy Viewpoints
    STRATEGY_VIEWPOINTS = [
      "Strategy",
      "Capability Map",
      "Outcome Realization",
      "Resource Map"
    ].freeze

    # Implementation and Migration Viewpoints
    IMPLEMENTATION_AND_MIGRATION_VIEWPOINTS = [
      "Project",
      "Migration",
      "Implementation and Migration"
    ].freeze

    # Other Viewpoints
    Other_Viewpoints = %w[Stakeholder].freeze

    VIEWPOINTS_ENUM = [].concat(
                        COMPOSITION_VIEWPOINTS, SUPPORT_VIEWPOINTS, COOPERATION_VIEWPOINTS,
                        REALIZATION_VIEWPOINTS, STRATEGY_VIEWPOINTS,
                        IMPLEMENTATION_AND_MIGRATION_VIEWPOINTS
                      )
    ViewpointType = Strict::String.enum(*VIEWPOINTS_ENUM)

    ViewpointContentEnum = Strict::String.enum(%w[Details Coherence Overview])
    ViewpointContent = Strict::Array.member(ViewpointContentEnum).default([])

    ViewpointPurposeEnum = Strict::String.enum(%w[Designing Deciding Informing])
    ViewpointPurpose = Strict::Array.member(ViewpointPurposeEnum).default([])

    class Viewpoint < NamedReferenceable
      using DataModel::DiffableArray
      using DataModel::DiffablePrimitive

      attribute :concern, ConcernList
      attribute :viewpointPurpose, ViewpointPurpose.optional
      attribute :viewpointContent, ViewpointContent.optional
      attribute :allowedElementTypes, AllowedElementTypes
      attribute :allowedRelationshipTypes, AllowedRelationshipTypes
      attribute :modelingNotes, Strict::Array.member(ModelingNote).default([])
    end

    Dry::Types.register_class(Viewpoint)
    ViewpointList = Strict::Array.member(Viewpoint).default([])
  end
end
