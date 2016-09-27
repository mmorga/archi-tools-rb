# frozen_string_literal: true
module Archimate
  module Model
    class Relationship < Dry::Struct::Value
      attribute :id, Types::Strict::String
      attribute :type, Types::Strict::String
      attribute :source, Types::Strict::String
      attribute :target, Types::Strict::String
      attribute :name, Types::Strict::String.optional
      attribute :documentation, Types::DocumentationList
      attribute :properties, Types::PropertiesList

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
