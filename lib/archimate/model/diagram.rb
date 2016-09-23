# frozen_string_literal: true
module Archimate
  module Model
    class Diagram < Dry::Struct::Value
      attribute :id, Archimate::Types::Strict::String
      attribute :name, Archimate::Types::Coercible::String
      attribute :documentation, Archimate::Types::Coercible::Array
      attribute :properties, Archimate::Types::Coercible::Array
      attribute :children, Archimate::Types::Coercible::Hash
      attribute :viewpoint, Archimate::Types::Coercible::String
      attribute :element_references, Archimate::Types::Coercible::Array

      def self.create(options = {})
        new_opts = {
          name: nil,
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
