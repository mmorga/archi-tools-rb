# frozen_string_literal: true
module Archimate
  module Cli
    class Merge
      attr_reader :base, :local, :remote, :merged, :messages

      def self.merge(base_file, local_file, remote_file, merged_file, message_io = STDERR)
        base = Archimate::ArchiFileReader.read(base_file)
        local = Archimate::ArchiFileReader.read(local_file)
        remote = Archimate::ArchiFileReader.read(remote_file)
        merged = merged_file

        my_merge = Merge.new(base, local, remote, merged, message_io)
        my_merge.merge
      end

      def initialize(base, local, remote, merged, message_io = STDERR)
        @base = base
        @local = local
        @remote = remote
        @merged = merged
        @message_io = message_io
      end

      def merge
        merge = Archimate::Diff::Merge.three_way(base, local, remote)

        @message_io.puts "Conflicts:"
        merge.conflicts.each { |d| @message_io.puts d }
      end
    end
  end
end
