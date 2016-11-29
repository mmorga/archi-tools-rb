# frozen_string_literal: true
module Archimate
  module DataModel
    class Relationship < Dry::Struct
      include With
      include DiffableStruct

      constructor_type :schema

      attribute :id, Strict::String
      attribute :type, Strict::String
      attribute :source, Strict::String
      attribute :target, Strict::String
      attribute :access_type, Coercible::Int.optional
      attribute :name, Strict::String.optional
      attribute :documentation, DocumentationList
      attribute :properties, PropertiesList

      def clone
        Relationship.new(
          id: id.clone,
          type: type.clone,
          source: source.clone,
          target: target.clone,
          name: name&.clone,
          access_type: access_type,
          documentation: documentation.map(&:clone),
          properties: properties.map(&:clone)
        )
      end

      def to_s
        HighLine.color(
          "#{AIO.data_model(type)}<#{id}>[#{HighLine.color(name || '', [:black, :underline])}]",
          :on_light_magenta
        ) + " #{source} -> #{target}"
      end

      def element_reference
        [@source, @target]
      end
    end
    Dry::Types.register_class(Relationship)
  end
end
