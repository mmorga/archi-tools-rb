# frozen_string_literal: true
module Archimate
  module DataModel
    class Element < IdentifiedNode
      attribute :label, Strict::String.optional

      alias name label

      def clone
        Element.new(
          id: id.clone,
          type: type&.clone,
          label: label&.clone,
          documentation: documentation.map(&:clone),
          properties: properties.map(&:clone)
        )
      end

      def to_s
        AIO.layer_color(layer, "#{type}<#{id}>[#{label}]")
      end

      def layer
        Constants::ELEMENT_LAYER.fetch(type, "None")
      end

      # TODO move to dynamic method creation
      def composed_by
        in_model.relationships.select { |r|
          r.type == "CompositionRelationship" && r.target == id
        }.map { |r|
          in_model.lookup(r.source)
        }
      end

      # TODO move to dynamic method creation
      def composes
        in_model.relationships.select { |r|
          r.type == "CompositionRelationship" && r.source == id
        }.map { |r|
          in_model.lookup(r.target)
        }
      end
    end
    Dry::Types.register_class(Element)
  end
end
