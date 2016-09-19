# frozen_string_literal: true
module Archimate
  module Cli
    class Diff
      attr_reader :local, :remote

      def self.diff(local_file, remote_file, message_io = STDERR)
        local = Archimate::ArchiFileReader.read(local_file)
        remote = Archimate::ArchiFileReader.read(remote_file)

        my_diff = Diff.new(local, remote, message_io)
        my_diff.diff
      end

      def initialize(local, remote, message_io = STDERR)
        @local = local
        @remote = remote
        @message_io = message_io
      end

      # Going to treat remote as gospel and add in diffs from local

      # A context sensive 3-way merge is what I want for this customized so that it
      # intelligently works for archi files.

      # Caveat - I don't like folders under model layers - so I'll not bother trying to make those work

      # Should translate to work with meff files with minor changes

      # Should also facilitate a merge of two models with no common base - though more work

      # The entities that I care about are:
      # * Model (really only care about name, purpose/documentation, properties)
      # * Model Entities
      # * Connectors (Junction variations) - same as model entities AFAIK
      # * Relations
      # * Diagrams
      # * Organization (Folders)

      # New node (id not in original doc)
      # Node renamed (id matches, type is same, name changes) -> rename (see warn level based on use of node)
      # Node id conflict (id matches, type is diff) -> re-id node and otherwise treat as add (see id re-mapping section)
      # Node content differs
      #   - @name
      #   - documentation
      #   - property
      def diff
        diffs = Archimate.diff(local, remote)

        diffs.each { |d| @message_io.puts d }

        @message_io.puts "\n\n#{diffs.size} Differences"

        diffs
      end
    end
  end
end
