# frozen_string_literal: true
module Archimate
  module DataModel
    class Element < IdentifiedNode
      attribute :folder_id, Strict::String.optional

      def to_s
        AIO.layer_color(layer, "#{type}<#{id}>[#{name}]")
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
    end
    Dry::Types.register_class(Element)
  end
end
