# frozen_string_literal: true
require "set"

module Archimate
  module Model
    class Model
      attr_reader :id
      attr_accessor :name, :documentation, :properties, :elements, :organization, :relationships, :diagrams

      def initialize(id = nil, name = nil)
        @id = id
        @name = name
        @documentation = []
        @properties = []
        # TODO: need a way to support keeping these elements in order
        # TODO: element diff should indicate insert after element id - maintain order
        @elements = {}
        @organization = {}
        @relationships = {}
        @diagrams = {}
        yield self if block_given?
      end

      def dup
        Model.new(id, name) do |copy|
          copy.documentation = Array.new(documentation)
          copy.properties = Array.new(properties)
          copy.elements = elements.dup
          copy.organization = organization.dup
          copy.relationships = relationships.dup
          copy.diagrams = diagrams.dup
        end
      end

      def ==(other)
        [:id, :name, :documentation, :properties, :elements, :organization,
         :relationships, :diagrams].all? { |a| send(a) == other.send(a) }
      end

      def add_element(el)
        @elements[el.id] = el
      end

      def apply_diff(diff)
        if diff.kind == :insert
          if diff.to.is_a?(Element)
            add_element(diff.to)
          end
        end
      end

      def ref_set
        @ref_set ||= Set.new(relationship_element_references + diagram_element_references)
      end

      def relationship_element_references
        @relationship_element_references ||= relationships.map(&:element_references).flatten.uniq
      end

      def diagram_element_references
        @diagram_element_references ||= diagrams.values.map(&:element_references).flatten.uniq
      end

      def unref_set
        @unref_set ||= model_set - ref_set
      end

      def unrefed_ids
        @unrefed_ids ||= unref_set + (relation_ids - relation_ref_ids)
      end
    end
  end
end
