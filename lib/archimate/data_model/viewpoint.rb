# frozen_string_literal: true

module Archimate
  module DataModel
    class Viewpoint
      include Comparison
      include Referenceable

      # @!attribute [r] id
      # @return [String]
      model_attr :id
      # @!attribute [r] name
      # @return [LangString]
      model_attr :name
      # @!attribute [r] documentation
      # @return [PreservedLangString]
      model_attr :documentation, default: nil
      # # @!attribute [r] other_elements
      # @return [Array<AnyElement>]
      model_attr :other_elements, default: []
      # # @!attribute [r] other_attributes
      # @return [Array<AnyAttribute>]
      model_attr :other_attributes, default: []
      # type here was used for the Element/Relationship/Diagram type
      # @!attribute [r] type
      # @return [String, NilClass]
      model_attr :type, default: nil
      # @!attribute [r] concerns
      # @return [Array<Concern>]
      model_attr :concerns, default: []
      # @!attribute [r] viewpoint_purposes
      # @return [Array<ViewpointPurposeEnum>]
      model_attr :viewpoint_purposes, default: []
      # @!attribute [r] viewpoint_contents
      # @return [Array<ViewpointContentEnum>]
      model_attr :viewpoint_contents, default: []
      # @!attribute [r] allowed_element_types
      # @return [Array<Elements::*>]
      model_attr :allowed_element_types, default: []
      # @!attribute [r] allowed_relationship_types
      # @return [Array<Relationships::*>]
      model_attr :allowed_relationship_types, default: []
      # @!attribute [r] modeling_notes
      # @return [Array<ModelingNote>]
      model_attr :modeling_notes, default: []

      def select_elements(from_elements)
        from_elements.select { |el| allowed_element_types.include?(el.class) }
      end

      def select_relationships(from_relationships)
        from_relationships.select { |rel| allowed_relationship_types.include?(rel.class) }
      end
    end
  end
end
