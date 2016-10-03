# frozen_string_literal: true
module Archimate
  module DataModel
    class Diagram < Dry::Struct::Value
      attribute :id, Strict::String
      attribute :name, Strict::String
      attribute :viewpoint, Strict::String.optional
      attribute :documentation, DocumentationList
      attribute :properties, PropertiesList
      attribute :children, ChildHash
      attribute :element_references, Strict::Array.member(Strict::String)
      attribute :connection_router_type, Strict::Int.optional # TODO: fill this in, should be an enum
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
    end
  end
end
