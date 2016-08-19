# frozen_string_literal: true
#
# The point of this script is to identify elements that aren't a part of any
# relationship and not referenced on any diagrams.

require "nokogiri"
require "ruby-progressbar"
require "set"

module Archimate
  class Cleanup
    FOLDER_XPATHS = [
      "folder[type=\"business\"]",
      "folder[type=\"application\"]",
      "folder[type=\"technology\"]",
      "folder[type=\"motivation\"]",
      "folder[type=\"implementation_migration\"]",
      "folder[type=\"connectors\"]"
    ].freeze

    RELATION_XPATHS = [
      "folder[type=\"relations\"]",
      "folder[type=\"derived\"]"
    ].freeze

    DIAGRAM_XPATHS = [
      "folder[type=\"diagrams\"]"
    ].freeze

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
      @trash = ArchiMate.new_xml_doc("<deleted></deleted>")
      @model_set = nil
    end

    def doc
      @doc ||= Document.read(infile)
    end

    def elements
      @elements ||= report_size("Evaluating %s elements", doc.css(FOLDER_XPATHS.join(",")).css('element[id]'))
    end

    def model_set
      @model_set ||= report_size(
        "Found %s model items",
        Set.new(elements.each_with_object([]) { |i, a| a << i.attr("id") })
      )
    end

    def diagrams_folder
      @diagrams_folder ||= doc.css(DIAGRAM_XPATHS.join(","))
    end

    def relations_folders
      @relations_folder ||= doc.css(RELATION_XPATHS.join(","))
    end

    def ref_set
      @ref_set ||= report_size(
        "Found references to %s items",
        Set.new(
          relations_folders.css("element[source],element[target]").each_with_object(
            diagrams_folder.css("[archimateElement]").each_with_object([]) { |i, a| a << i.attr("archimateElement") }
          ) { |i, a| a << i.attr("source") << i.attr("target") }
        )
      )
    end

    def relation_ids
      @relation_ids ||= Set.new(relations_folders.css("element[id]").each_with_object([]) { |i, a| a << i.attr("id") })
    end

    def relation_ref_ids
      @relation_ref_ids ||= Set.new(
        diagrams_folder.css("[relationship]").each_with_object([]) { |i, a| a << i.attr("relationship") }
      )
    end

    def unref_set
      @unref_set ||= model_set - ref_set
    end

    def unrefed_ids
      @unrefed_ids ||= unref_set + (relation_ids - relation_ref_ids)
    end

    def progressbar
      @progressbar ||= ProgressBar.create(
        title: "Elements",
        total: unrefed_ids.size,
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
      unrefed_ids.each do |id|
        ns = doc.css("##{id}")
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

    def report_size(str, collection)
      # TODO: convert to error_helper module
      puts format(str, collection.size)
      collection
    end
  end
end
