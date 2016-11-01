# frozen_string_literal: true
module Archimate
  module DataModel
    class Relationship < Dry::Struct
      include DataModel::With

      attribute :parent_id, Strict::String.optional
      attribute :id, Strict::String
      attribute :type, Strict::String
      attribute :source, Strict::String
      attribute :target, Strict::String
      attribute :name, Strict::String.optional
      attribute :documentation, DocumentationList
      attribute :properties, PropertiesList

      def self.create(options = {})
        new_opts = {
          parent_id: nil,
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
          parent_id: parent_id&.clone,
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
        "#{type_name} #{source} -> #{target} docs[#{documentation.size}] props[#{properties.size}]"
      end

      def type_name
        "#{type.black.italic}<#{id}>[#{(name || '').black.underline}]".on_light_magenta
      end

      def describe(model, options = {})
        s = type_name
        if options.include?(:from_model)
          from_model = options[:from_model]
          s += " #{from_model.elements[options[:from]].describe(from_model)} -> #{model.elements[options[:to]].describe(model)}"
        end
        s
      end

      def element_reference
        [@source, @target]
      end
      Dry::Types.register_class(Relationship)
    end
  end
end
