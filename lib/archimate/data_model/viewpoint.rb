# frozen_string_literal: true

module Archimate
  module DataModel
    class Viewpoint
      include Comparison

      # @return [String]
      model_attr :id
      # @return [LangString]
      model_attr :name
      # @return [PreservedLangString]
      model_attr :documentation
      # # @return [Array<AnyElement>]
      model_attr :other_elements
      # # @return [Array<AnyAttribute>]
      model_attr :other_attributes
      # type here was used for the Element/Relationship/Diagram type
      # @return [String, NilClass]
      model_attr :type
      # @return [Array<Concern>]
      model_attr :concerns
      # @return [Array<ViewpointPurposeEnum>]
      model_attr :viewpoint_purposes
      # @return [Array<ViewpointContentEnum>]
      model_attr :viewpoint_contents
      # @return [Array<ElementType>]
      model_attr :allowed_element_types
      # @return [Array<RelationshipType>]
      model_attr :allowed_relationship_types
      # @return [Array<ModelingNote>]
      model_attr :modeling_notes

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
