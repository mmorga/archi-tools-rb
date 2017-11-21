# frozen_string_literal: true

require "nokogiri"

#
# The point of this script is to identify elements that aren't a part of any
# relationship and not referenced on any diagrams.
module Archimate
  module Cli
    class Cleanup
      attr_reader :model

      def initialize(model, output, removed_items_io)
        @model = model
        @output = output
        @removed_items_io = removed_items_io
        @model_set = nil
        @progressbar = ProgressIndicator.new(total: unreferenced_nodes.size, title: "Unreferenced Elements and Relationships")
        @unref_set = []
      end

      # detects elements not referenced by a relationship or a diagram
      def unreferenced_elements
        model
          .elements
          .select { |el| el.references.none?(&ref_is_relationship_or_diagram) }
      end

      def unreferenced_relationships
        model
          .relationships
          .select { |rel| rel.references.none?(&ref_is_relationship_or_diagram) }
      end

      def unreferenced_nodes
        unreferenced_relationships + unreferenced_elements
      end

      def destroy_nodes(nodes)
        nodes.each do |unreferenced_node|
          unreferenced_node.destroy
          @removed_items_io.write(Color.uncolor(unreferenced_node.to_s) + "\n")
          @unref_set << unreferenced_node
          @progressbar.increment
        end
      end

      def clean
        return unless model

        rels = unreferenced_relationships
        $stdout.puts "Unreferenced Relationships: #{rels.size}"
        destroy_nodes rels
        els = unreferenced_elements
        $stdout.puts "Unreferenced Elements: #{els.size}"
        destroy_nodes els

        $stdout.puts "Found #{@unref_set.size} model items unreferenced by diagram or relationships"
        Archimate::FileFormats::ArchiFileWriter.write(model, @output)
      end

      private

      def ref_is_relationship_or_diagram
        ->(ref) { ref.is_a?(DataModel::Relationship) || ref.is_a?(DataModel::Diagram) }
      end
    end
  end
end
