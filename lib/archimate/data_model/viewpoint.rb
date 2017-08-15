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
                        [COMPOSITION_VIEWPOINTS, SUPPORT_VIEWPOINTS, COOPERATION_VIEWPOINTS,
                         REALIZATION_VIEWPOINTS, STRATEGY_VIEWPOINTS,
                         IMPLEMENTATION_AND_MIGRATION_VIEWPOINTS].flatten
                      )

    # ViewpointType = Strict::String.enum(*VIEWPOINTS_ENUM).optional

    VIEWPOINT_CONTENT_ENUM = %w[Details Coherence Overview]

    # ViewpointContentEnum = Strict::String.enum(*VIEWPOINT_CONTENT_ENUM)

    VIEWPOINT_PURPOSE_ENUM = %w[Designing Deciding Informing]

    # ViewpointPurposeEnum = Strict::String.enum(*VIEWPOINT_PURPOSE_ENUM)

    class Viewpoint
      include Comparison

      model_attr :id # Identifier
      model_attr :name # LangString
      model_attr :documentation # PreservedLangString
      # model_attr :other_elements # Strict::Array.member(AnyElement).default([])
      # model_attr :other_attributes # Strict::Array.member(AnyAttribute).default([])
      model_attr :type # Strict::String.optional # Note: type here was used for the Element/Relationship/Diagram type
      model_attr :concerns # Strict::Array.member(Concern).default([])
      model_attr :viewpoint_purposes # Strict::Array.member(ViewpointPurposeEnum).default([])
      model_attr :viewpoint_contents # Strict::Array.member(ViewpointContentEnum).default([])
      model_attr :allowed_element_types # Strict::Array.member(ElementType).default([])
      model_attr :allowed_relationship_types # Strict::Array.member(RelationshipType).default([])
      model_attr :modeling_notes # Strict::Array.member(ModelingNote).default([])

      def initialize(id:, name:, documentation: nil, type: nil,
                     concerns: [], viewpoint_purposes: [],
                     viewpoint_contents: [], allowed_element_types: [],
                     allowed_relationship_types: [], modeling_notes: [])
        @id = id
        @name = name
        @documentation = documentation
        @type = type
        @concerns = concerns
        @viewpoint_purposes = viewpoint_purposes
        @viewpoint_contents = viewpoint_contents
        @allowed_element_types = allowed_element_types
        @allowed_relationship_types = allowed_relationship_types
        @modeling_notes = modeling_notes
      end
    end
  end
end
