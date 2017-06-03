# frozen_string_literal: true
module Archimate
  module Cli
    class Diff
      attr_reader :local, :remote

      def self.diff(local_file, remote_file)
        local = Archimate.read(local_file)
        remote = Archimate.read(remote_file)

        my_diff = Diff.new(local, remote)
        my_diff.diff
      end

      def initialize(local, remote)
        @local = local
        @remote = remote
      end

      def diff
        diffs = Archimate.diff(local, remote)

        diffs.each { |d| puts d }

        puts "\n\n#{diffs.size} Differences"

        diffs
      end
    end
  end
end
