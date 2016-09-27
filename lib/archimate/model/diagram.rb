# frozen_string_literal: true
module Archimate
  module Model
    class Diagram < Dry::Struct::Value
      attribute :id, Archimate::Types::Strict::String
      attribute :name, Archimate::Types::Strict::String
      attribute :viewpoint, Archimate::Types::Strict::String.optional
      attribute :documentation, Archimate::Types::DocumentationList
      attribute :properties, Archimate::Types::PropertiesList
      attribute :children, Archimate::Types::ChildHash
      attribute :element_references, Archimate::Types::ElementIdList

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
