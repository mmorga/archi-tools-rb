# frozen_string_literal: true

require "parallel"

module Archimate
  module Cli
    class Merge
      include Logging

      attr_reader :base, :local, :remote, :merged_file

      def self.merge(base_file, remote_file, local_file, merged_file)
        debug { "Reading base file: #{base_file}, local file: #{local_file}, remote file: #{remote_file}" }
        base, local, remote = Parallel.map([base_file, local_file, remote_file], in_processes: 3) do |file|
          Archimate.read(file)
        end
        Logging.debug { "Merged file is #{merged_file}" }

        Merge.new(base, local, remote, merged_file).run_merge
      end

      def initialize(base, local, remote, merged_file)
        @base = base
        @local = local
        @remote = remote
        @merged_file = merged_file
        @merge = Archimate::Diff::Merge.new
      end

      def run_merge
        debug { "Starting merging" }
        merged, conflicts = @merge.three_way(base, local, remote)
        # TODO: there should be no conflicts here
        debug do
          <<~MSG
            Done merging
            #{conflicts}
          MSG
        end

        File.open(merged_file, "w") do |file|
          # TODO: this should be controlled by the options and the defaulted to the read format
          debug { "Serializing" }
          Archimate::FileFormats::ArchiFileWriter.write(merged, file)
        end
      end
    end
  end
end
