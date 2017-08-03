# frozen_string_literal: true

require 'forwardable'
# require 'parallel'
require 'archimate/diff/conflicts/base_conflict'
require 'archimate/diff/conflicts/deleted_items_child_updated_conflict'
require 'archimate/diff/conflicts/deleted_items_referenced_conflict'
require 'archimate/diff/conflicts/path_conflict'

module Archimate
  module Diff
    class Conflicts
      extend Forwardable

      attr_reader :base_local_diffs
      attr_reader :base_remote_diffs

      def_delegator :@conflicts, :empty?
      def_delegator :@conflicts, :size
      def_delegator :@conflicts, :first
      def_delegator :@conflicts, :map
      def_delegator :@conflicts, :each

      include Archimate::Logging

      def initialize(base_local_diffs, base_remote_diffs)
        @base_local_diffs = base_local_diffs
        @base_remote_diffs = base_remote_diffs
        @conflict_finders = [PathConflict, DeletedItemsChildUpdatedConflict, DeletedItemsReferencedConflict]
        @conflicts = nil
        @conflicting_diffs = nil
        @unconflicted_diffs = nil
        # TODO: consider making this an argument
        @conflict_resolver = Cli::ConflictResolver.new
      end

      # TODO: refactor this method elsewhere
      # resolve iterates through the set of conflicting diffs asking the user
      # (if running interactively) and return the set of diffs that can be applied.
      #
      # To keep diffs reasonably human readable in logs, the local diffs should
      # be applied first followed by the remote diffs.
      def resolve
        debug do
          <<~MSG
            Filtering out #{conflicts.size} conflicts from #{base_local_diffs.size + base_remote_diffs.size} diffs
            Remaining diffs #{unconflicted_diffs.size}
          MSG
        end

        conflicts.each_with_object(unconflicted_diffs) do |conflict, diffs|
          # TODO: this will result in diffs being out of order from their
          # original order. diffs should be flagged as conflicted and
          # this method should instead remove the conflicted flag.
          diffs.concat(@conflict_resolver.resolve(conflict))
          # TODO: if the conflict is resolved, it should be removed from the
          # @conflicts array.
        end
      end

      def conflicts
        @conflicts ||= find_conflicts
      end

      def conflicting_diffs
        @conflicting_diffs ||= conflicts.map(&:diffs).flatten
      end

      def unconflicted_diffs
        @unconflicted_diffs ||=
          (base_local_diffs + base_remote_diffs) - conflicting_diffs
      end

      def to_s
        "Conflicts:\n\n#{conflicts.map(&:to_s).join("\n\n")}\n"
      end

      private

      def find_conflicts
        # TODO: Running this in parallel breaks currently.
        # @conflicts = Parallel.map(@conflict_finders, in_processes: 3) { |cf_class|
        @conflicts = @conflict_finders.map { |cf_class|
          cf_class.new(base_local_diffs, base_remote_diffs).conflicts
        }.flatten
      end
    end
  end
end
