# frozen_string_literal: true

# This module takes an ArchiMate model and builds a JSONL representation of it
# suitable for import into ArangoDB
#
# Node Schema:
#   Properties:
#     name: Element.name
#     nodelId: Element.id
#     layer: Element.layer
#     documentation: Element.documentation
#     Element.properties
#      ("prop:#{Property.key}"): Property.value
#   Labels:
#     Element.type
#
# Edge Schema:
#   Properties:
#     weight (of Relationship Type as in table below)
#     relationshipId: Relationship.id
#     name: Relationship.name
#     documentation: Relationship.documentation
#     accessType: Relationship.access_type
#   Labels:
#     Relationship.type
#
# | Weight | Name           |
# |--------+----------------|
# |      1 | Association    |
# |      2 | Access         |
# |      3 | Used by        |
# |      4 | Realization    |
# |      5 | Assignment     |
# |      6 | Aggregation    |
# |      7 | Composition    |
# |      8 | Flow           |
# |      9 | Triggering     |
# |     10 | Grouping       |
# |     11 | Junction       |
# |     12 | Specialization |
# Structural stronger than Dependency Relationships
# ServingRelationship == UsedByRelationship
require "json"

module Archimate
  module Export
    def self.clean_json(hash)
      JSON.generate(hash.delete_if { |_k, v| v.nil? || (v.is_a?(String) && v.empty?) })
    end

    class PropertiesHash
      attr_reader :properties

      def initialize(properties)
        @properties = properties
      end

      def to_h
        properties.each_with_object({}) do |property, hash|
          hash[property.key.to_s] = property.value.to_s
        end
      end
    end

    class JsonlNode
      attr_reader :element

      def initialize(element)
        @element = element
      end

      # n:BusinessActor
      # `layer`: "Business",
      # `name`: Felix,
      # `nodeId`: "d8e75068-df75-4c21-a2af-fab5c195687a"
      def to_jsonl
        Export.clean_json(
          _key: element.id,
          name: element.name&.to_s,
          layer: element.layer&.name&.to_s&.delete(" "),
          type: element.type,
          documentation: element.documentation&.to_s,
          properties: PropertiesHash.new(element.properties).to_h
        )
      end
    end

    class JsonlEdge
      attr_reader :relationship

      def initialize(relationship)
        @relationship = relationship
      end

      def to_jsonl
        Export.clean_json(
          _key: relationship.id,
          _from: relationship.source,
          _to: relationship.target,
          name: relationship.name&.to_s,
          type: relationship.type,
          accessType: relationship.access_type,
          documentation: relationship.documentation&.to_s,
          properties: PropertiesHash.new(relationship.properties).to_h,
          weight: relationship.weight
        )
      end
    end

    class Jsonl
      attr_reader :output_io

      def initialize(output_io)
        @output_io = output_io
      end

      def to_jsonl(model)
        write_nodes(model.elements)
        write_relationships(model.relationships)
      end

      def write_nodes(elements)
        elements.each { |element| write(JsonlNode.new(element).to_jsonl) }
      end

      def write_relationships(relationships)
        relationships.each { |relationship| write(JsonlEdge.new(relationship).to_jsonl) }
      end

      private

      def write(str)
        @output_io.puts(str)
      end
    end
  end
end
