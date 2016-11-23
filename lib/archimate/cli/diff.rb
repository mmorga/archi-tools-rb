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

      def diff
        diffs = Archimate.diff(local, remote)

        diffs.each { |d| @message_io.puts d }

        @message_io.puts "\n\n#{diffs.size} Differences"

        diffs
      end
    end
  end
end
