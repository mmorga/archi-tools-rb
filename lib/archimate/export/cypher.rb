# frozen_string_literal: true

# This module takes an ArchiMate model and builds GraphML representation of it.
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

module Archimate
  module Export
    class Cypher
      attr_reader :output_io

      def initialize(output_io)
        @output_io = output_io
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
          props = add_docs(
            {
              layer: element.layer.to_s,
              name: element.name.to_s,
              nodeId: element.id
            }.merge(
              element.properties.each_with_object({}) do |prop, memo|
                memo["prop:#{prop.key}"] = prop.value unless prop.value.nil?
              end
            ), element.documentation
          )

          write(
            node(
              element.type,
              props
            )
          )
        end
      end

      def create_indexes(elements)
        write "\n// Indexes\n"
        elements.map(&:type).uniq.each do |label|
          write "CREATE INDEX ON :#{label}(name);"
          write "CREATE INDEX ON :#{label}(nodeId);"
        end
      end

      def write_relationships(relationships)
        write "\n// Relationships\n"
        relationships.each do |rel|
          write relationship(rel)
        end
      end

      private

      def node(label, properties = {})
        "CREATE (n:#{label} #{props(properties)});"
      end

      def relationship(rel)
        "MATCH #{source(rel)},#{target(rel)} " \
        "CREATE (s)-#{relationship_def(rel)}->(t);"
      end

      def props(properties)
        "{ #{properties.reject { |_k, v| v.nil? }.map { |k, v| "`#{k}`: #{v.inspect}" }.join(', ')} }"
      end

      def source(rel)
        "(s #{props(nodeId: rel.source.id)})"
      end

      def add_docs(h, documentation)
        return h unless documentation
        t = documentation.to_s.strip
        return h if t.empty?
        h.merge(documentation: t)
      end

      def relationship_def(rel)
        h = add_docs(
          {
            name: rel.name.to_s,
            relationshipId: rel.id,
            accessType: rel.access_type,
            weight: rel.weight
          }, rel.documentation
        )
        "[r:#{rel.type} #{props(h)}]"
      end

      def target(rel)
        "(t #{props(nodeId: rel.target.id)})"
      end

      def write(str)
        @output_io.puts(str)
      end
    end
  end
end
