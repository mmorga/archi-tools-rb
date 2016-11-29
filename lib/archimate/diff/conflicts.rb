# frozen_string_literal: true

require 'forwardable'

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

      def initialize(aio)
        @aio = aio
        @conflicts = []
        @cwhere = {}
        @base_local_diffs = []
        @base_remote_diffs = []
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

      def conflict_finders
        @conflict_finders ||= Conflicts.constants
                                       .select { |k| Conflicts.const_get(k).is_a? Class }
                                       .reject { |k| k == :BaseConflict || k =~ /Test$/ }
                                       .map { |k| Conflicts.const_get(k) }
      end

      def find(base_local_diffs, base_remote_diffs)
        @base_local_diffs = base_local_diffs
        @base_remote_diffs = base_remote_diffs
        conflict_finders.each do |cf_class|
          cf = cf_class.new(base_local_diffs, base_remote_diffs)
          aio.debug cf.describe
          add_conflicts(cf.conflicts)
        end
      end
    end
  end
end
