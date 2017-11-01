# frozen_string_literal: true

module Archimate
  module DataModel
    class Viewpoint
      include Comparison

      # @!attribute [r] id
      #   @return [String]
      model_attr :id
      # @!attribute [r] name
      #   @return [LangString]
      model_attr :name
      # @!attribute [r] documentation
      #   @return [PreservedLangString]
      model_attr :documentation
      # # @!attribute [r] other_elements
      #   @return [Array<AnyElement>]
      model_attr :other_elements
      # # @!attribute [r] other_attributes
      #   @return [Array<AnyAttribute>]
      model_attr :other_attributes
      # type here was used for the Element/Relationship/Diagram type
      # @!attribute [r] type
      #   @return [String, NilClass]
      model_attr :type
      # @!attribute [r] concerns
      #   @return [Array<Concern>]
      model_attr :concerns
      # @!attribute [r] viewpoint_purposes
      #   @return [Array<ViewpointPurposeEnum>]
      model_attr :viewpoint_purposes
      # @!attribute [r] viewpoint_contents
      #   @return [Array<ViewpointContentEnum>]
      model_attr :viewpoint_contents
      # @!attribute [r] allowed_element_types
      #   @return [Array<ElementType>]
      model_attr :allowed_element_types
      # @!attribute [r] allowed_relationship_types
      #   @return [Array<Relationships::*>]
      model_attr :allowed_relationship_types
      # @!attribute [r] modeling_notes
      #   @return [Array<ModelingNote>]
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
