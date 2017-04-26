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
when ' | Association    |
when ' | Access         |
when ' | Used by        |
when ' | Realization    |
when ' | Assignment     |
when ' | Aggregation    |
when ' | Composition    |
when ' | Flow           |
when ' | Triggering     |
when ' | Grouping       |
when ' | Junction       |
when ' | Specialization |

module Archimate
  module Export
    class Cypher
      attr_reader :aio

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
        case t
        when 'AssociationRelationship'
          1
        when 'AccessRelationship'
          2
        when 'UsedByRelationship'
          3
        when 'RealizationRelationship'
          4
        when 'AssignmentRelationship'
          5
        when 'AggregationRelationship'
          6
        when 'CompositionRelationship'
          7
        when 'FlowRelationship'
          8
        when 'TriggeringRelationship'
          9
        when 'GroupingRelationship'
          10
        when 'JunctionRelationship'
          11
        when 'SpecializationRelationship'
          12
        else
          0
        end
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
