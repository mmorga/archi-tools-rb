# frozen_string_literal: true
module Archimate
  module Cli
    class Merge
      attr_reader :base, :local, :remote, :merged_file, :aio

      def self.merge(base_file, remote_file, local_file, merged_file, aio = Archimate::AIO.new(verbose: true))
        aio.debug "Reading base file: #{base_file}"
        base = Archimate.read(base_file, aio)
        aio.debug "Reading local file: #{local_file}"
        local = Archimate.read(local_file, aio)
        aio.debug "Reading remote file: #{remote_file}"
        remote = Archimate.read(remote_file, aio)
        aio.debug "Merged file is #{merged_file}"

        Merge.new(base, local, remote, merged_file, aio).run_merge
      end

      def initialize(base, local, remote, merged_file, aio)
        @base = base
        @local = local
        @remote = remote
        @merged_file = merged_file
        @aio = aio
        @merge = Archimate::Diff::Merge.new(@aio)
      end

      def run_merge
        aio.debug "Starting merging"
        merged, conflicts = @merge.three_way(base, local, remote)
        aio.debug "Done merging"
        aio.debug conflicts # TODO: there should be no conflicts here

        File.open(merged_file, "w") do |f|
          # TODO: this should be controlled by the options and the defaulted to the read format
          aio.debug "Serializing"
          Archimate::FileFormats::ArchiFileWriter.write(merged, f)
        end
      end
    end
  end
end
