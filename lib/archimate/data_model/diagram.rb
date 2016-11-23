# frozen_string_literal: true
module Archimate
  module DataModel
    class Diagram < Dry::Struct
      include DataModel::With

      attribute :parent_id, Strict::String
      attribute :id, Strict::String
      attribute :name, Strict::String
      attribute :viewpoint, Strict::String.optional # TODO: change to (int?) or make parser deal with this and make enum
      attribute :documentation, DocumentationList
      attribute :properties, PropertiesList
      attribute :children, Strict::Array.member(Child)
      attribute :connection_router_type, Coercible::Int.optional # TODO: fill this in, should be an enum
      attribute :type, Strict::String.optional
      attribute :background, Coercible::Int.optional

      def self.create(options = {})
        new_opts = {
          documentation: [],
          properties: [],
          children: [],
          viewpoint: nil,
          connection_router_type: nil,
          type: nil,
          background: nil
        }.merge(options)
        Diagram.new(new_opts)
      end

      def clone
        Diagram.new(
          parent_id: parent_id.clone,
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

      def to_s
        "#{'Diagram'.cyan}<#{id}>[#{name.white.underline}]"
      end
    end
    Dry::Types.register_class(Diagram)
  end
end
