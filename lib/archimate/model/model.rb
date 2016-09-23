# frozen_string_literal: true
require "set"

module Archimate
  module Model
    class Model < Dry::Struct::Value
      attribute :id, Archimate::Types::Strict::String
      attribute :name, Archimate::Types::Strict::String
      attribute :documentation, Archimate::Types::DocumentationList
      attribute :properties, Archimate::Types::PropertiesList
      attribute :elements, Archimate::Types::Strict::Hash
      attribute :organization, Archimate::Types::Organization
      attribute :relationships, Archimate::Types::Strict::Hash
      attribute :diagrams, Archimate::Types::Strict::Hash

      def self.create(options = {})
        new_opts = {
          documentation: [],
          properties: [],
          elements: {},
          organization: Organization.create,
          relationships: {},
          diagrams: {}
        }.merge(options)
        Model.new(new_opts)
      end

      def with(options = {})
        Model.new(to_h.merge(options))
      end

      def apply_diff(diff)
        model = with
        if diff.kind == :insert
          if diff.to.is_a?(Element)
            el = diff.to
            new_elements = {}.merge(model.elements)
            new_elements[el.id] = el
            model = model.with(elements: new_elements)
          end
        end
        model
      end

      def ref_set
        Set.new(relationship_element_references + diagram_element_references)
      end

      def relationship_element_references
        relationships.map(&:element_references).flatten.uniq
      end

      def diagram_element_references
        diagrams.values.map(&:element_references).flatten.uniq
      end

      def unref_set
        model_set - ref_set
      end

      def unrefed_ids
        unref_set + (relation_ids - relation_ref_ids)
      end
    end
  end
end
