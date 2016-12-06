# frozen_string_literal: true

require 'forwardable'
require 'archimate/diff/conflicts/base_conflict'
require 'archimate/diff/conflicts/deleted_items_child_updated_conflict'
require 'archimate/diff/conflicts/deleted_items_referenced_conflict'
require 'archimate/diff/conflicts/path_conflict'

module Archimate
  module Diff
    class Conflicts
      extend Forwardable

      attr_reader :conflicts
      attr_reader :aio
      attr_reader :base_local_diffs
      attr_reader :base_remote_diffs

      def_delegator :@conflicts, :empty?
      def_delegator :@conflicts, :size
      def_delegator :@conflicts, :first
      def_delegator :@conflicts, :map
      def_delegator :@conflicts, :each

      def initialize(base_local_diffs, base_remote_diffs, aio)
        @base_local_diffs = base_local_diffs
        @base_remote_diffs = base_remote_diffs
        @aio = aio
        @conflicts = []
        @conflict_finders = [PathConflict, DeletedItemsChildUpdatedConflict, DeletedItemsReferencedConflict]
      end

      def resolve
        find

        aio.debug "Filtering out #{conflicts.size} conflicts from #{base_local_diffs.size + base_remote_diffs.size} diffs"
        remaining_diffs = filter_diffs(base_remote_diffs + base_local_diffs)

        aio.debug "Remaining diffs #{remaining_diffs.size}"

        conflicts.each_with_object(remaining_diffs) do |conflict, diffs|
          diffs.concat(aio.resolve_conflict(conflict))
        end
      end

      def add_conflicts(conflict)
        conflicts.concat(Array(conflict))
        self
      end

      def diffs
        conflicts.map(&:diffs).flatten
      end

      def filter_diffs(diff_list)
        conflict_diffs = diffs
        diff_list.reject { |diff| conflict_diffs.include?(diff) }
      end

      def to_s
        "Conflicts:\n\n#{conflicts.map(&:to_s).join("\n\n")}\n"
      end

      def find
        @conflict_finders.each do |cf_class|
          cf = cf_class.new(base_local_diffs, base_remote_diffs)
          aio.debug cf.describe
          add_conflicts(cf.conflicts)
        end
      end
    end
  end
end
