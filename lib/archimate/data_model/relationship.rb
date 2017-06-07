# frozen_string_literal: true

module Archimate
  module DataModel
    RelationshipTypeEnum = %w[
      Composition
      Aggregation
      Assignment
      Realization
      Serving
      Access
      Influence
      Triggering
      Flow
      Specialization
      Association
    ].freeze
    RelationshipType = Strict::String.enum(*RelationshipTypeEnum)
    AllowedRelationshipTypes = Strict::Array.member(RelationshipType).default([])

    # A base relationship type that can be extended by concrete ArchiMate types.
    #
    # Note that RelationshipType is abstract, so one must have derived types of this type. this is indicated in xml
    # by having a tag name of "relationship" and an attribute of xsi:type="AccessRelationship" where AccessRelationship is
    # a derived type from RelationshipType.
    class Relationship < Concept
      attribute :source, Strict::String
      attribute :target, Strict::String
      attribute :access_type, Coercible::Int.optional # TODO: turn this into an enum
      attribute :properties, PropertiesList # Note: this is not in the model under element
      # it's added under Real Element

      def replace(entity, with_entity)
        @source = with_entity.id if source == entity.id
        @target = with_entity.id if target == entity.id
      end

      def to_s
        Archimate::Color.color(
          "#{Archimate::Color.data_model(type)}<#{id}>[#{Archimate::Color.color(name&.strip || '', %i[black underline])}]",
          :on_light_magenta
        ) + " #{source_element} -> #{target_element}"
      end

      def description
        [
          name.nil? ? nil : "#{name}:",
          FileFormats::ArchimateV2::RELATION_VERBS.fetch(type, nil)
        ].compact.join(" ")
      end

      def referenced_identified_nodes
        [@source, @target].compact
      end

      def source_element
        element_by_id(source)
      end

      def target_element
        element_by_id(target)
      end

      # Diagrams that this element is referenced in.
      def diagrams
        @diagrams ||= in_model.diagrams.select do |diagram|
          diagram.relationship_ids.include?(id)
        end
      end

      # Copy any attributes/docs, etc. from each of the others into the original.
      #     1. Child `label`s with different `xml:lang` attribute values
      #     2. Child `documentation` (and different `xml:lang` attribute values)
      #     3. Child `properties`
      #     4. Any other elements
      # source and target don't change on a merge
      def merge(relationship)
        super
        access_type ||= relationship.access_type
      end
    end
    Dry::Types.register_class(Relationship)
  end
end
