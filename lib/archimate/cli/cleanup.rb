# frozen_string_literal: true
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
        model.unreferenced_nodes.each do |id|
          ns = model.lookup(id)
          puts "Found duplicate ids: #{ns}" if ns.size > 1
          unreferenced_node = ns[0]
          trash.root.add_child unreferenced_node.dup
          prev_sib = unreferenced_node.previous_sibling
          if prev_sib.instance_of?(Nokogiri::XML::Text) && prev_sib.content.strip.empty?
            ns << prev_sib
          end
          ns.remove
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
