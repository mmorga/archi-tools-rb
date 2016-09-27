# frozen_string_literal: true
module Archimate
  module Model
    class Diagram < Dry::Struct::Value
      attribute :id, Types::Strict::String
      attribute :name, Types::Strict::String
      attribute :viewpoint, Types::Strict::String.optional
      attribute :documentation, Types::DocumentationList
      attribute :properties, Types::PropertiesList
      attribute :children, Types::ChildHash
      attribute :element_references, Types::ElementIdList

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
