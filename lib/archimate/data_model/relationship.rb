# frozen_string_literal: true

module Archimate
  module DataModel
    RELATIONSHIP_TYPE_ENUM = %w[
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

    RelationshipType = Strict::String.enum(*RELATIONSHIP_TYPE_ENUM)

    ACCESS_TYPE = %w[Access Read Write ReadWrite]
    AccessTypeEnum = Strict::String.enum(*ACCESS_TYPE)

    # A base relationship type that can be extended by concrete ArchiMate types.
    #
    # Note that RelationshipType is abstract, so one must have derived types of this type. this is indicated in xml
    # by having a tag name of "relationship" and an attribute of xsi:type="AccessRelationship" where AccessRelationship is
    # a derived type from RelationshipType.
    class Relationship < Dry::Struct
      # Used only for testing
      # include With

      # specifies constructor style for Dry::Struct
      constructor_type :strict_with_defaults

      attribute :id, Identifier
      attribute :name, LangString.optional.default(nil)
      attribute :documentation, PreservedLangString.optional.default(nil)
      # attribute :other_elements, Strict::Array.member(AnyElement).default([])
      # attribute :other_attributes, Strict::Array.member(AnyAttribute).default([])
      attribute :type, Strict::String.optional # Note: type here was used for the Element/Relationship/Diagram type
      attribute :properties, Strict::Array.member(Property).default([])
      attribute :source, Element # TODO: This could be an Element or Relationship, is this optional?
      attribute :target, Element # TODO: This could be an Element or Relationship, is this optional?
      attribute :access_type, AccessTypeEnum.optional.default(nil)

      def dup
        raise "no dup dum dum"
      end

      def clone
        raise "no clone dum dum"
      end

      def replace(entity, with_entity)
        @source = with_entity.id if source == entity.id
        @target = with_entity.id if target == entity.id
      end

      def to_s
        Archimate::Color.color(
          "#{Archimate::Color.data_model(type)}<#{id}>[#{Archimate::Color.color(name&.strip || '', %i[black underline])}]",
          :on_light_magenta
        ) + " #{source} -> #{target}"
      end

      def description
        [
          name.nil? ? nil : "#{name}:",
          FileFormats::ArchimateV2::RELATION_VERBS.fetch(type, nil)
        ].compact.join(" ")
      end

      # TODO: remove when it doesn't break diff merge conflicts
      # @deprecated
      def referenced_identified_nodes
        [@source, @target].compact
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
