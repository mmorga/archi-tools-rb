# frozen_string_literal: true
module Archimate
  module DataModel
    class Relationship < Dry::Struct
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

      def clone
        Relationship.new(
          id: id.clone,
          type: type.clone,
          source: source.clone,
          target: target.clone,
          name: name.nil? ? nil : name.clone,
          documentation: documentation.map(&:clone),
          properties: properties.map(&:clone)
        )
      end

      def to_s
        "#{type}<#{id}> #{name} #{source} -> #{target} docs[#{documentation.size}] props[#{properties.size}]"
      end

      def type_name
        "#{type.blue.italic}[#{name.black.underline}]".on_light_magenta
      end

      def describe(model)
        "#{type_name} #{model.elements[source].short_desc}->#{model.elements[target].short_desc}"
      end

      def element_reference
        [@source, @target]
      end
      Dry::Types.register_class(Relationship)
    end
  end
end
