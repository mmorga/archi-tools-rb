# frozen_string_literal: true
module Archimate
  module Cli
    class Diff
      attr_reader :local, :remote

      def self.diff(local_file, remote_file, aio)
        local = Archimate.read(local_file, aio)
        remote = Archimate.read(remote_file, aio)

        my_diff = Diff.new(local, remote, aio)
        my_diff.diff
      end

      def initialize(local, remote, aio)
        @local = local
        @remote = remote
        @aio = aio
      end

      def diff
        diffs = Archimate.diff(local, remote)

        diffs.each { |d| @aio.puts d }

        @aio.puts "\n\n#{diffs.size} Differences"

        diffs
      end
    end
  end
end
