# frozen_string_literal: true

module Archimate
  module DataModel
    # Something that can be referenced in the model.
    class Referenceable < ArchimateNode
      attribute :id, Identifier
      attribute :name, Strict::String.optional # TODO: Strict::Array.member(LangString).constrained(min_size: 1)

      attribute :documentation, DocumentationGroup
      # attribute :grp_any, Strict::Array.member(AnyNode).default([])
      # attribute :other_attributes, Strict::Array.member(AnyAttribute).default([])
      # attribute :properties, PropertiesList # Note: Referenceable doesn't have properties in the spec
      attribute :type, Strict::String.optional # Note: type here was used for the Element/Relationship/Diagram type

      private

      def find_my_index
        id
      end

      # name isn't merged
      def merge(node)
        documentation.concat(node.documentation)
        properties.concat(node.properties)
      end
    end
  end
end
