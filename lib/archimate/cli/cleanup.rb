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
        @trash = Archimate.new_xml_doc("<deleted></deleted>")
        @model_set = nil
      end

      # TODO: refactor into AIO
      def progressbar
        @progressbar ||= ProgressBar.create(
          title: "Elements",
          total: @doc.unrefed_ids.size,
          format: "%t %a %e %b\u{15E7}%i %p%%",
          progress_mark: ' ',
          remainder_mark: "\u{FF65}"
        )
      end

      def remove_unreferenced_nodes
        model.unrefed_ids.each do |id|
          ns = model.lookup(id)
          puts "Found duplicate ids: #{ns}" if ns.size > 1
          trash.root.add_child ns[0].dup
          prev_sib = ns[0].previous_sibling
          if prev_sib.instance_of?(Nokogiri::XML::Text) && prev_sib.content.strip.empty?
            ns << prev_sib
          end
          ns.remove
          progressbar.increment
        end
      end

      def write_trash
        options[:saveremoved].write(trash)
      end

      def clean
        return if model.nil?

        remove_unreferenced_nodes
        puts "Found #{unref_set.size} model items unreferenced by diagram or relationships"
        Archimate::ArchiFileWriter.write(model, output)
        write_trash
      end
    end
  end
end
