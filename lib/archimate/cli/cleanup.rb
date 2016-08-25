# frozen_string_literal: true
#
# The point of this script is to identify elements that aren't a part of any
# relationship and not referenced on any diagrams.

require "ruby-progressbar"
require "set"

module Archimate
  module Cli
    class Cleanup
      TEXT_SUBSTITUTIONS = [
        ['&#13;', '&#xD;'],
        ['"', '&quot;'],
        ['&gt;', '>']
      ].freeze

      def self.cleanup(input, output, options)
        cleaner = new(input, output, options)
        cleaner.clean
      end

      def initialize(input, output, options)
        @input = input
        @output = output
        @options = options
        @doc = nil
        @trash = Archimate.new_xml_doc("<deleted></deleted>")
        @model_set = nil
      end

      # TODO: consider refactoring this so the document comes in to the ctor
      def doc
        @doc ||= Document.read(infile)
      end

      def progressbar
        @progressbar ||= ProgressBar.create(
          title: "Elements",
          total: @doc.unrefed_ids.size,
          format: "%t %a %e %b\u{15E7}%i %p%%",
          progress_mark: ' ',
          remainder_mark: "\u{FF65}"
        )
      end

      def process_text(doc_str)
        %w(documentation content).each do |tag|
          TEXT_SUBSTITUTIONS.each do |m|
            from = m[0]
            to = m[1]
            doc_str.gsub!(%r{<#{tag}>([^<]*#{from}[^<]*)</#{tag}>}) do |str|
              str.gsub(from, to)
            end
          end
        end
      end

      def remove_unreferenced_nodes
        @doc.unrefed_ids.each do |id|
          ns = @doc.element_by_identifier(id)
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
        return if doc.nil?

        puts "Found #{unref_set.size} model items unreferenced by diagram or relationships"
        output.write(process_text(doc.to_s))
        remove_unreferenced_nodes
        write_trash
      end
    end
  end
end
