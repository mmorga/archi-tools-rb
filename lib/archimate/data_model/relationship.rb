# frozen_string_literal: true
module Archimate
  module DataModel
    class Relationship < Dry::Struct::Value
      include DataModel::With

      attribute :id, Strict::String
      attribute :type, Strict::String
      attribute :source, Strict::String
      attribute :target, Strict::String
      attribute :name, Strict::String.optional
      attribute :documentation, DocumentationList
      attribute :properties, PropertiesList

      def self.create(options = {})
        new_opts = {
          name: nil,
          documentation: [],
          properties: []
        }.merge(options)
        Relationship.new(new_opts)
      end

      def to_s
        "#{type}<#{id}> #{name} #{source} -> #{target} docs[#{documentation.size}] props[#{properties.size}]"
      end

      def element_reference
        [@source, @target]
      end
      Dry::Types.register_class(Relationship)
    end
  end
end
