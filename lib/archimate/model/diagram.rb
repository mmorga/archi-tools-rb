# frozen_string_literal: true
module Archimate
  module Model
    class Diagram < Dry::Struct::Value
      attribute :id, Archimate::Model::Strict::String
      attribute :name, Archimate::Model::Strict::String
      attribute :viewpoint, Archimate::Model::Strict::String.optional
      attribute :documentation, Archimate::Model::DocumentationList
      attribute :properties, Archimate::Model::PropertiesList
      attribute :children, Archimate::Model::ChildHash
      attribute :element_references, Archimate::Model::ElementIdList

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
