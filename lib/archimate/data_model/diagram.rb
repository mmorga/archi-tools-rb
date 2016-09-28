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

      def self.create(options = {})
        new_opts = {
          documentation: [],
          properties: [],
          children: {},
          viewpoint: nil,
          element_references: []
        }.merge(options)
        Diagram.new(new_opts)
      end
    end
  end
end
