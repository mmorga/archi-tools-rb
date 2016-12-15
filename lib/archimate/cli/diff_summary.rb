# frozen_string_literal: true
require 'forwardable'

module Archimate
  module Cli
    class DiffSummary
      DIFF_KINDS = %w(Delete Change Insert).freeze

      extend Forwardable

      def_delegator :@aio, :puts
      def_delegator :@aio, :debug

      attr_reader :local, :remote

      def self.diff(local_file, remote_file, options = { verbose: true })
        aio = AIO.new(options)
        aio.debug "Reading #{local_file}"
        local = Archimate.read(local_file)
        aio.debug "Reading #{remote_file}"
        remote = Archimate.read(remote_file)

        my_diff = DiffSummary.new(local, remote, aio)
        my_diff.diff
      end

      def initialize(local, remote, aio)
        @local = local
        @remote = remote
        @aio = aio
        @summary = Hash.new { |hash, key| hash[key] = Hash.new { |k_hash, k_key| k_hash[k_key] = 0 } }
      end

      def diff
        debug "Calculating differences"
        diffs = Archimate.diff(local, remote)

        puts HighLine.color("Summary of differences", :headline)
        puts "\n"

        summary_element_diffs = diffs.group_by { |diff| diff.summary_element.class.to_s.split("::").last }
        summarize_elements summary_element_diffs["Element"]
        summarize "Folder", summary_element_diffs["Folder"]
        summarize "Relationship", summary_element_diffs["Relationship"]
        summarize_diagrams summary_element_diffs["Diagram"]

        puts "Total Diffs: #{diffs.size}"
      end

      def summarize(title, diffs)
        return if diffs.nil? || diffs.empty?
        by_kind = diffs.group_by(&:kind)
        puts color(title)
        DIFF_KINDS.each do |kind|
          puts format("  #{color(kind)}: #{by_kind[kind]&.size}") if by_kind.key?(kind)
        end
      end

      def summarize_elements(diffs)
        return if diffs.nil? || diffs.empty?
        puts HighLine.color("Elements", :headline)
        by_layer = diffs.group_by { |diff| diff.summary_element.layer }
        summarize "Business", by_layer["Business"]
        summarize "Application", by_layer["Application"]
        summarize "Technology", by_layer["Technology"]
        summarize "Motivation", by_layer["Motivation"]
        summarize "Implementation and Migration", by_layer["Implementation and Migration"]
        summarize "Connectors", by_layer["Connectors"]
      end

      def summarize_diagrams(diffs)
        return if diffs.nil? || diffs.empty?
        puts HighLine.color("Diagrams", :headline)

        by_kind = diagram_diffs_by_kind(diffs)
        %w(Delete Change Insert).each do |kind|
          next unless by_kind.key?(kind)
          diagram_names = by_kind[kind]
          puts "  #{color(kind)}"
          # TODO: make this magic number an option
          diagram_names[0..14].each { |diagram_name| puts "    #{diagram_name}" }
          puts "    ... and #{diagram_names.size - 15} more" if diagram_names.size > 15
        end
      end

      def color(kind)
        HighLine.color(kind, kind)
      end

      def diagram_diffs_by_kind(diffs)
        diffs
          .group_by(&:summary_element)
          .each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |(diagram, diagram_diffs), a|
          top_level_diff = diagram_diffs.find { |diff| diagram == diff.target.value }
          if top_level_diff
            a[top_level_diff.kind] << diagram.name
          else
            a["Change"] << diagram.name
          end
        end
      end
    end
  end
end
