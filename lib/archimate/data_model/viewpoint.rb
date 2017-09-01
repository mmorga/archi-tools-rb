# frozen_string_literal: true

module Archimate
  module DataModel
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
