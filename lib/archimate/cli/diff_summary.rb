# frozen_string_literal: true
require 'forwardable'

module Archimate
  module Cli
    class DiffSummary
      extend Forwardable

      def_delegator :@aio, :puts
      def_delegator :@aio, :debug

      attr_reader :local, :remote

      def self.diff(local_file, remote_file, options = {})
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
        @summary = {
          elements: {
            deleted: 0,
            changed: 0,
            added: 0
          },
          relationships: {
            deleted: 0,
            changed: 0,
            added: 0
          },
          diagrams: {
            deleted: 0,
            changed: 0,
            added: 0
          }
        }
      end

      def diff
        debug "Calculating differences"
        diffs = Archimate.diff(local, remote)

        debug "Processing #{diffs.size} Differences"
        diffs.each do |diff|
          debug diff.inspect
        end
      end
    end
  end
end
