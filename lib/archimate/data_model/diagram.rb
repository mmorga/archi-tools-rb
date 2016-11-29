# frozen_string_literal: true
module Archimate
  module DataModel
    class Diagram < Dry::Struct
      include With
      include DiffableStruct

      constructor_type :schema

      attribute :id, Strict::String
      attribute :name, Strict::String
      attribute :viewpoint, Coercible::String.optional
      attribute :documentation, DocumentationList
      attribute :properties, PropertiesList
      attribute :children, Strict::Array.member(Child).default([])
      attribute :connection_router_type, Coercible::Int.optional # TODO: fill this in, should be an enum
      attribute :type, Strict::String.optional
      attribute :background, Coercible::Int.optional

      def clone
        Diagram.new(
          id: id.clone,
          name: name.clone,
          viewpoint: viewpoint&.clone,
          documentation: documentation.map(&:clone),
          properties: properties.map(&:clone),
          children: children.map(&:clone),
          connection_router_type: connection_router_type,
          type: type&.clone,
          background: background
        )
      end

      def element_references
        children.each_with_object([]) do |i, a|
          a.concat(i.element_references)
        end
      end

      # Return the relationship id for all source_connections in this diagram
      def relationships
        children.each_with_object([]) do |i, a|
          a.concat(i.relationships)
        end
      end

      def source_connections
        children.each_with_object([]) do |i, a|
          a.concat(i.all_source_connections)
        end
      end

      def to_s
        "#{AIO.data_model('Diagram')}<#{id}>[#{HighLine.color(name, [:white, :underline])}]"
      end
    end
    Dry::Types.register_class(Diagram)
  end
end
