require 'forwardable'

module Archimate
  module Diff
    class Conflicts
      extend Forwardable
      attr_reader :conflicts

      def_delegator :@conflicts, :empty?
      def_delegator :@conflicts, :size
      def_delegator :@conflicts, :first

      def initialize
        @conflicts = []
        @cwhere = {}
      end

      def <<(conflict)
        conflict_ary = Array(conflict)
        # TODO: remove this - it's for testing/debug only
        raise TypeError, "Must be a Conflict was a '#{conflict.class}'" unless conflict_ary.all? { |i| i.is_a?(Archimate::Diff::Conflict) }
        # TODO: remove this block - it's for debug only
        conflict_ary.each { |c| raise ArgumentError, "Trying to add a duplicate conflict #{c} into #{self}" if conflicts.include?(c) }
        conflicts.concat(conflict_ary)
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
    end
  end
end
