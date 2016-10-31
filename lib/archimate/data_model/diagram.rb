# frozen_string_literal: true
module Archimate
  module DataModel
    class Diagram < Dry::Struct
      include DataModel::With

      attribute :id, Strict::String
      attribute :name, Strict::String
      attribute :viewpoint, Strict::String.optional
      attribute :documentation, DocumentationList
      attribute :properties, PropertiesList
      attribute :children, ChildHash
      attribute :element_references, Strict::Array.member(Strict::String)
      attribute :connection_router_type, Coercible::Int.optional # TODO: fill this in, should be an enum
      attribute :type, Strict::String.optional

      def self.create(options = {})
        new_opts = {
          documentation: [],
          properties: [],
          children: {},
          viewpoint: nil,
          element_references: [],
          connection_router_type: nil,
          type: nil
        }.merge(options)
        Diagram.new(new_opts)
      end

      def clone
        Diagram.new(
          id: id.clone,
          name: name.clone,
          viewpoint: viewpoint.nil? ? nil : viewpoint.clone,
          documentation: documentation.map(&:clone),
          properties: properties.map(&:clone),
          children: children.each_with_object({}) { |(k, v), a| a[k] = v.clone },
          element_references: element_references.map(&:clone),
          connection_router_type: connection_router_type,
          type: type.nil? ? nil : type.clone
        )
      end

      # Return the relationship id for all source_connections in this diagram
      def relationships
        children.each_with_object([]) do |(_id, child), a|
          a.concat(child.relationships)
        end
      end

      def describe(model)
        "#{'Diagram'.cyan.italic}[#{name.white.underline}]"
      end
    end
  end
end
