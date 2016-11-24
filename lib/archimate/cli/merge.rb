# frozen_string_literal: true
module Archimate
  module Cli
    class Merge
      attr_reader :base, :local, :remote, :merged_file, :aio

      def self.merge(base_file, remote_file, local_file, merged_file, aio = Archimate::AIO.new(verbose: true))
        aio.debug "Reading base file: #{base_file}"
        base = Archimate.read(base_file)
        aio.debug "Reading local file: #{local_file}"
        local = Archimate.read(local_file)
        aio.debug "Reading remote file: #{remote_file}"
        remote = Archimate.read(remote_file)
        aio.debug "Merged file is #{merged_file}"

        Merge.new(base, local, remote, merged_file, aio).run_merge
      end

      def initialize(base, local, remote, merged_file, aio)
        @base = base
        @local = local
        @remote = remote
        @merged_file = merged_file
        @aio = aio
      end

      def run_merge
        aio.debug "Starting merging"
        merge = Archimate::Diff::Merge.three_way(base, local, remote, aio)
        aio.debug "Done merging"
        aio.debug merge.conflicts

        # TODO: Resolve manual conflicts

        File.open(merged_file, "w") do |f|
          Archimate::ArchiFileWriter.write(merge.merged, f)
        end
      end
    end
  end
end
