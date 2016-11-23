# frozen_string_literal: true
module Archimate
  module DataModel
    class Element < Dry::Struct
      include DataModel::With

      attribute :parent_id, Strict::String
      attribute :id, Strict::String
      attribute :type, Strict::String.optional
      attribute :label, Strict::String.optional
      attribute :documentation, DocumentationList
      attribute :properties, PropertiesList

      alias name label

      def self.create(options = {})
        new_opts = {
          type: nil,
          label: nil,
          documentation: [],
          properties: []
        }.merge(options)
        Element.new(new_opts)
      end

      def clone
        Element.new(
          parent_id: parent_id.clone,
          id: id.clone,
          type: type&.clone,
          label: label&.clone,
          documentation: documentation.map(&:clone),
          properties: properties.map(&:clone)
        )
      end

      def to_s
        AIO.layer_color(layer, "#{type.light_black}<#{id}>[#{label}]")
      end

      def layer
        Archimate::Constants::ELEMENT_LAYER.fetch(@type, "None")
      end

      def composed_by
        in_model.relationships.select { |r|
          r.type == "CompositionRelationship" && r.target == id
        }.map { |r|
          in_model.lookup(r.source)
        }
      end

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
