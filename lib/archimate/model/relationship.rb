# frozen_string_literal: true
module Archimate
  module Model
    class Relationship < Dry::Struct::Value
      attribute :id, Strict::String
      attribute :type, Archimate::Model::Strict::String
      attribute :source, Archimate::Model::Strict::String
      attribute :target, Archimate::Model::Strict::String
      attribute :name, Archimate::Model::Strict::String.optional
      attribute :documentation, Archimate::Model::DocumentationList
      attribute :properties, Archimate::Model::PropertiesList

      def self.create(options = {})
        new_opts = {
          name: nil,
          documentation: [],
          properties: []
        }.merge(options)
        Relationship.new(new_opts)
      end

      def with(options = {})
        Relationship.new(to_h.merge(options))
      end

      def to_s
        "#{type}<#{id}> #{name} #{source} -> #{target} docs[#{documentation.size}] props[#{properties.size}]"
      end

      def element_reference
        [@source, @target]
      end
    end
  end
end
