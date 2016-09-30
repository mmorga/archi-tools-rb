# frozen_string_literal: true
require "set"

module Archimate
  module DataModel
    class Model < Dry::Struct::Value
      attribute :id, Strict::String
      attribute :name, Strict::String
      attribute :documentation, DocumentationList
      attribute :properties, PropertiesList
      attribute :elements, Strict::Hash
      attribute :organization, Organization
      attribute :relationships, Strict::Hash
      attribute :diagrams, Strict::Hash

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

      # returns a copy of self with element added
      # (or replaced with) the given element
      def insert_element(element)
        with(
          elements:
            elements.merge(element.id => element)
        )
      end

      # returns a copy of self with relationship added
      # (or replaced with) the given relationship
      def insert_relationship(relationship)
        with(
          relationships:
            relationships.merge(relationship.id => relationship)
        )
      end

      # TODO: consider refactoring all of the ref/unref methods to another class
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
