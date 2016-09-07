# frozen_string_literal: true
module Archimate
  module Diff
    class StringDiff
      attr_reader :s1, :s2

      def initialize(s1, s2)
        @s1 = s1
        @s2 = s2
      end

      def diffs
        return [] if s1 == s2
        return [Difference.insert(s2)] if s1.nil?
        return [Difference.delete(s1)] if s2.nil?
        [Difference.new(:change, nil, nil, s1, s2)]
      end
    end
  end
end
