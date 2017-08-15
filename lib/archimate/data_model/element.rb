# frozen_string_literal: true

module Archimate
  module DataModel
    ElementTypeEnum = %w[BusinessActor BusinessRole BusinessCollaboration BusinessInterface
                         BusinessProcess BusinessFunction BusinessInteraction BusinessEvent BusinessService
                         BusinessObject Contract Representation Product
                         ApplicationComponent ApplicationCollaboration ApplicationInterface ApplicationFunction
                         ApplicationInteraction ApplicationProcess ApplicationEvent ApplicationService DataObject
                         Node Device SystemSoftware TechnologyCollaboration TechnologyInterface Path
                         CommunicationNetwork TechnologyFunction TechnologyProcess TechnologyInteraction
                         TechnologyEvent TechnologyService Artifact Equipment Facility DistributionNetwork Material
                         Stakeholder Driver Assessment Goal Outcome
                         Principle Requirement Constraint Meaning Value
                         Resource Capability CourseOfAction
                         WorkPackage Deliverable ImplementationEvent Plateau Gap
                         Grouping Location
                         AndJunction OrJunction].freeze

    CompositeTypeEnum = %w[Grouping Location].freeze

    RelationshipConnectorEnum = %w[AndJunction OrJunction].freeze

    ElementEnumType = [].concat([ElementTypeEnum, CompositeTypeEnum, RelationshipConnectorEnum]).freeze

    ElementType = String # Strict::String.enum(*ElementEnumType)

    # A base element type that can be extended by concrete ArchiMate types.
    #
    # Note that ElementType is abstract, so one must have derived types of this type. this is indicated in xml
    # by having a tag name of "element" and an attribute of xsi:type="BusinessRole" where BusinessRole is
    # a derived type from ElementType.
    #
    # TODO: Possible Make this abstract with concrete implementations for all valid element types
    class Element
      include Comparison

      model_attr :id # Identifier
      model_attr :name # LangString.optional.default(nil)
      model_attr :documentation, writable: true # PreservedLangString.optional.default(nil)
      # model_attr :other_elements # Strict::Array.member(AnyElement).default([])
      # model_attr :other_attributes # Strict::Array.member(AnyAttribute).default([])
      model_attr :type # Strict::String.optional # Note: type here was used for the Element/Relationship/Diagram type
      model_attr :properties # Strict::Array.member(Property).default([])

      def initialize(id:, name:, documentation: nil, type: nil, properties: [])
        @id = id
        @name = name
        @documentation = documentation
        @type = type
        @properties = properties
      end

      def to_s
        Archimate::Color.layer_color(layer, "#{type}<#{id}>[#{name}]")
      end

      def layer
        Constants::ELEMENT_LAYER.fetch(type, "None")
      end

      # Diagrams that this element is referenced in.
      def diagrams
        @diagrams ||= in_model.diagrams.select do |diagram|
          diagram.element_ids.include?(id)
        end
      end

      # Relationships that this element is referenced in.
      def relationships
        @relationships ||= in_model.relationships.select do |relationship|
          relationship.source == id || relationship.target == id
        end
      end

      # Copy any attributes/docs, etc. from each of the others into the original.
      #     1. Child `label`s with different `xml:lang` attribute values
      #     2. Child `documentation` (and different `xml:lang` attribute values)
      #     3. Child `properties`
      #     4. Any other elements
      def merge(element)
        super
        element.diagrams.each { |diagram| diagram.replace(element, self) }
        element.relationships.each { |relationship| relationship.replace(element, self) }
        element.organization.remove(element.id)
      end
    end
  end
end
