# frozen_string_literal: true

# This module takes an ArchiMate model and builds GraphML representation of it.
#
# Node Schema:
#   Properties:
#     name: Element.label
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


module Archimate
  module Export
    class Cypher
      attr_reader :aio

      WEIGHTS = {
        'GroupingRelationship' => 0,
        'JunctionRelationship' => 0,
        'AssociationRelationship' => 0,
        'SpecialisationRelationship' => 1,
        'FlowRelationship' => 2,
        'TriggeringRelationship' => 3,
        'InfluenceRelationship' => 4,
        'AccessRelationship' => 5,
        'UsedByRelationship' => 6,
        'RealisationRelationship' => 7,
        'AssignmentRelationship' => 8,
        'AggregationRelationship' => 9,
        'CompositionRelationship' => 10
      }

      def initialize(aio)
        @aio = aio
      end

      def to_cypher(model)
        write_cypher_header(model)
        write_nodes(model.elements)
        create_indexes(model.elements)
        write_relationships(model.relationships)
        # TODO: write properties
      end

      def write_cypher_header(model)
        write "// Cypher import script of ArchiMate model #{model.name}. Produced #{DateTime.now}\n"
      end

      def write_nodes(elements)
        write "\n// Nodes\n"
        elements.each do |element|
          write(
            node(
              element.type,
              layer: element.layer.delete(" "),
              name: element.label,
              nodeId: element.id,
              documentation: element.documentation.map(&:text).join("\n")
            )
          )
        end
      end

      def create_indexes(elements)
        write "\n// Indexes\n"
        elements.map(&:type).uniq.each do |label|
          write "CREATE INDEX ON :#{label}(name);"
          write "CREATE INDEX ON :#{label}(elementID);"
        end
      end

      def write_relationships(relationships)
        write "\n// Relationships\n"
        relationships.each do |rel|
          write relationship(rel)
        end
      end

      private

      def node(label, layer, properties = {})
        "CREATE (n:#{layer}:#{label} #{props(properties)});"
      end

      def relationship(rel)
        "MATCH #{source(rel)},#{target(rel)} " \
        "CREATE (s)-#{relationship_def(rel)}->(t);"
      end

      def props(properties)
        "{ #{properties.reject { |_k, v| v.nil? }.map { |k, v| "`prop:#{k}`: #{v.inspect}" }.join(', ')} }"
      end

      def source(rel)
        "(s #{props(elementID: rel.source)})"
      end

      def weight(t)
        return 0 unless WEIGHTS.include?(t)
        WEIGHTS[t]
      end

      def relationship_def(rel)
        "[r:#{rel.type} #{props(name: rel.name, relationshipID: rel.id, accessType: rel.access_type, weight: weight(rel.type), documentation: rel.documentation.map(&:text).join("\n"))}]"
      end

      def target(rel)
        "(t #{props(elementID: rel.target)})"
      end

      def write(str)
        @aio.output_io.puts(str)
      end
    end
  end
end
