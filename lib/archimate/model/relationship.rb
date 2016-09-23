# frozen_string_literal: true
module Archimate
  module Model
    class Relationship < Dry::Struct::Value
      attribute :id, Archimate::Types::Strict::String
      attribute :name, Archimate::Types::Strict::String.optional
      attribute :type, Archimate::Types::Strict::String
      attribute :source, Archimate::Types::Strict::String
      attribute :target, Archimate::Types::Strict::String
      attribute :documentation, Archimate::Types::DocumentationList
      attribute :properties, Archimate::Types::PropertiesList

      def self.create(options = {})
        new_opts = {
          name: nil,
          type: nil,
          source: nil,
          target: nil,
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
