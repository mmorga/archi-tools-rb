# frozen_string_literal: true
module Archimate
  module DataModel
    class Element < IdentifiedNode
      attribute :folder_id, Strict::String.optional

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

      def folder
        in_model.lookup(folder_id)
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
        element.folder.remove(element.id)
      end
    end
    Dry::Types.register_class(Element)
  end
end
