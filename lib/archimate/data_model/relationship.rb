# frozen_string_literal: true
module Archimate
  module DataModel
    class Relationship < Dry::Struct
      include DataModel::With

      attribute :parent_id, Strict::String
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

      def comparison_attributes
        [:@id, :@type, :@source, :@target, :@name, :@documentation, :@properties]
      end

      def clone
        Relationship.new(
          parent_id: parent_id.clone,
          id: id.clone,
          type: type.clone,
          source: source.clone,
          target: target.clone,
          name: name&.clone,
          documentation: documentation.map(&:clone),
          properties: properties.map(&:clone)
        )
      end

      def to_s
        "#{type.black.italic}<#{id}>[#{(name || '').black.underline}]".on_light_magenta + " #{source} -> #{target}"
      end

      def element_reference
        [@source, @target]
      end
      Dry::Types.register_class(Relationship)
    end
  end
end
