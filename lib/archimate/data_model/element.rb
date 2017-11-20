# frozen_string_literal: true

module Archimate
  module DataModel
    # A base element type that can be extended by concrete ArchiMate types.
    #
    # Note that ElementType is abstract, so one must have derived types of this
    # type. This is indicated in xml by having a tag name of +element+ and an
    # attribute of +xsi:type="BusinessRole"+ where +BusinessRole+ is a derived
    # type from [ElementType].
    class Element
      include Comparison
      include Referenceable
      include RelationshipReferences

      # @!attribute [r] id
      # @return [String]
      model_attr :id
      # @!attribute [r] name
      # @return [LangString, NilClass]
      model_attr :name
      # @!attribute [rw] documentation
      # @return [PreservedLangString, NilClass]
      model_attr :documentation, writable: true, default: nil
      # @!attribute [r] other_elements
      # @return [Array<AnyElement>]
      model_attr :other_elements, default: []
      # @!attribute [r] other_attributes
      # @return [Array<AnyAttribute>]
      model_attr :other_attributes, default: []
      # @!attribute [r] properties
      # @return [Array<Property>]
      model_attr :properties, default: []

      def to_s
        Archimate::Color.layer_color(layer, "#{type}<#{id}>[#{name}]")
      end

      def type
        self.class.name.split("::").last
      end

      def classification
        self.class::CLASSIFICATION
      end

      def layer
        self.class::LAYER
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

      # Diagrams that this entity is referenced in.
      def diagrams
        references.select { |ref| ref.is_a?(Diagram) }
      end
    end
  end
end
