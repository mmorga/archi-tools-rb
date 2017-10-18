# frozen_string_literal: true
require "nokogiri"

#
# The point of this script is to identify elements that aren't a part of any
# relationship and not referenced on any diagrams.

module Archimate
  module Cli
    class Cleanup
      attr_reader :model

      def self.cleanup(input, output, options)
        cleaner = new(Archimate.read(input), output, options)
        cleaner.clean
      end

      def initialize(model, output, options)
        @model = model
        @output = output
        @options = options
        @trash = Nokogiri::XML::Document.new("<deleted></deleted>")
        @model_set = nil
        @progressbar = ProgressIndicator.new(total: model.unreferenced_nodes.size, title: "Elements")
      end

      def remove_unreferenced_nodes
        model.unreferenced_nodes.each do |unreferenced_node|
          raise "This functionality is not implemeted yet"

          # TODO: this needs to be the XML serialization of the node
          trash.root.add_child unreferenced_node.dup
          # TODO: implement this
          # model.delete(unreferenced_node)
          @progressbar.increment
        end
      end

      def write_trash
        options[:saveremoved].write(trash)
      end

      def clean
        return unless model

        remove_unreferenced_nodes
        puts "Found #{unref_set.size} model items unreferenced by diagram or relationships"
        Archimate::ArchiFileWriter.write(model, output)
        write_trash
      end
    end
  end
end
