# frozen_string_literal: true
# This module takes an ArchiMate model and builds GraphML representation of it.
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
          write node(element.type, element.layer.delete(" "), name: element.label, elementID: element.id)
        end
      end

      def create_indexes(elements)
        write "\n// Indexes\n"
        elements.map(&:type).uniq.each do |label|
          write "CREATE INDEX ON :#{label}(name);"
          write "CREATE INDEX ON :#{label}(elementID);"
        end

        write "\n\nschema await\n\n"
      end

      def write_relationships(relationships)
        write "\n// Relationships\n"
        relationships.each do |rel|
          write relationship(rel)
        end
      end

      private

      # TODO: add the element layer as a label
      def node(label, layer, properties = {})
        "CREATE (n:#{layer}:#{label} #{props(properties)});"
      end

      def relationship(rel)
        "MATCH #{source(rel)},#{target(rel)} " \
        "CREATE (s)-#{relationship_def(rel)}->(t);"
      end

      def props(properties)
        "{ #{properties.reject { |_k, v| v.nil? }.map { |k, v| "#{k}: #{v.inspect}" }.join(', ')} }"
      end

      def source(rel)
        "(s #{props(elementID: rel.source)})"
      end

      def relationship_def(rel)
        "[r:#{rel.type} #{props(name: rel.name, elementID: rel.id, accessType: rel.access_type)}]"
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
