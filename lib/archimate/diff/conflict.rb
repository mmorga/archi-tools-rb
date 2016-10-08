# frozen_string_literal: true
module Archimate
  module Diff
    class Conflict
      attr_reader :base_local_diffs
      attr_reader :base_remote_diffs
      attr_reader :reason

      def initialize(base_local_diffs, base_remote_diffs, reason)
        @base_local_diffs = Array(base_local_diffs)
        @base_remote_diffs = Array(base_remote_diffs)
        @reason = reason
      end

      def to_s
        "CONFLICT: #{reason}\n" \
          "\tBase->Local Diff(s):\n\t\t#{base_local_diffs.map(&:to_s).join("\n\t\t")}" \
          "\n\tBase->Remote Diffs(s):\n\t\t#{base_remote_diffs.map(&:to_s).join("\n\t\t")}"
      end

      def ==(other)
        base_local_diffs == other.base_local_diffs &&
          base_remote_diffs == other.base_remote_diffs &&
          reason == other.reason
      end

      def diffs
        base_local_diffs + base_remote_diffs
      end
    end
  end
end
