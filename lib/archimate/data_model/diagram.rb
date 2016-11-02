# frozen_string_literal: true
module Archimate
  module DataModel
    class Diagram < Dry::Struct
      include DataModel::With

      attribute :parent_id, Strict::String
      attribute :id, Strict::String
      attribute :name, Strict::String
      attribute :viewpoint, Strict::String.optional
      attribute :documentation, DocumentationList
      attribute :properties, PropertiesList
      attribute :children, ChildHash
      # attribute :element_references, Strict::Array.member(Strict::String)
      attribute :connection_router_type, Coercible::Int.optional # TODO: fill this in, should be an enum
      attribute :type, Strict::String.optional

      def self.create(options = {})
        new_opts = {
          documentation: [],
          properties: [],
          children: {},
          viewpoint: nil,
          # element_references: [],
          connection_router_type: nil,
          type: nil
        }.merge(options)
        Diagram.new(new_opts)
      end

      def comparison_attributes
        [:@id, :@name, :@viewpoint, :@documentation, :@properties, :@children, :@connection_router_type, :@type]
      end

      def clone
        Diagram.new(
          parent_id: parent_id.clone,
          id: id.clone,
          name: name.clone,
          viewpoint: viewpoint&.clone,
          documentation: documentation.map(&:clone),
          properties: properties.map(&:clone),
          children: children.each_with_object({}) { |(k, v), a| a[k] = v.clone },
          # element_references: element_references.map(&:clone),
          connection_router_type: connection_router_type,
          type: type&.clone
        )
      end

      def element_references
        children.each_with_object([]) do |(_id, child), a|
          a.concat(child.element_references)
        end
      end

      # Return the relationship id for all source_connections in this diagram
      def relationships
        children.each_with_object([]) do |(_id, child), a|
          a.concat(child.relationships)
        end
      end

      def to_s
        "#{'Diagram'.cyan.italic}<#{id}>[#{name.white.underline}]"
      end
    end
  end
end
