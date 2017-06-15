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

    ElementEnumType = [].concat(ElementTypeEnum, CompositeTypeEnum, RelationshipConnectorEnum).freeze

    ElementType = Strict::String.enum(*ElementEnumType)

    AllowedElementTypes = Strict::Array.member(ElementType).default([])

    # A base element type that can be extended by concrete ArchiMate types.
    #
    # Note that ElementType is abstract, so one must have derived types of this type. this is indicated in xml
    # by having a tag name of "element" and an attribute of xsi:type="BusinessRole" where BusinessRole is
    # a derived type from ElementType.
    class Element < Concept
      attribute :organization_id, Strict::String.optional # Note: this is not from the model

      def to_s
        Archimate::Color.layer_color(layer, "#{type}<#{id}>[#{name}]")
      end

      def layer
        Constants::ELEMENT_LAYER.fetch(type, "None")
      end

      # TODO: move to dynamic method creation
      def composed_by
        in_model
          .relationships.select { |r| r.type == "CompositionRelationship" && r.target == id }
          .map { |r| in_model.lookup(r.source) }
      end

      # TODO: move to dynamic method creation
      def composes
        in_model
          .relationships
          .select { |r| r.type == "CompositionRelationship" && r.source == id }
          .map { |r| in_model.lookup(r.target) }
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

      def organization
        in_model.lookup(organization_id)
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
    Dry::Types.register_class(Element)
  end
end
