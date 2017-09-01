# frozen_string_literal: true

module Archimate
  module DataModel
    ACCESS_TYPE = %w[Access Read Write ReadWrite].freeze
    AccessTypeEnum = String # Strict::String.enum(*ACCESS_TYPE)

    # A base relationship type that can be extended by concrete ArchiMate types.
    #
    # Note that RelationshipType is abstract, so one must have derived types of this type. this is indicated in xml
    # by having a tag name of "relationship" and an attribute of xsi:type="AccessRelationship" where AccessRelationship is
    # a derived type from RelationshipType.
    class Relationship
      include Comparison

      model_attr :id # Identifier
      model_attr :name # LangString.optional.default(nil)
      model_attr :documentation # PreservedLangString.optional.default(nil)
      # model_attr :other_elements # Strict::Array.member(AnyElement).default([])
      # model_attr :other_attributes # Strict::Array.member(AnyAttribute).default([])
      model_attr :type # Strict::String.optional # Note: type here was used for the Element/Relationship/Diagram type
      model_attr :properties # Strict::Array.member(Property).default([])
      model_attr :source, comparison_attr: :id, writable: true # Element # TODO: This could be an Element or Relationship, is this optional?
      model_attr :target, comparison_attr: :id, writable: true # Element # TODO: This could be an Element or Relationship, is this optional?
      model_attr :access_type # AccessTypeEnum.optional.default(nil)

      def initialize(id:, name: nil, documentation: nil, type: nil,
                     properties: [], source:, target:, access_type: nil)
        @id = id
        @name = name
        @documentation = documentation
        @type = type
        @properties = properties
        @source = source
        @target = target
        @access_type = access_type
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
          RELATION_VERBS.fetch(type, nil)
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
  end
end
