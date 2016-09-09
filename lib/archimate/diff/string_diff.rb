# frozen_string_literal: true
module Archimate
  module Diff
    class StringDiff
      def diffs(s1, s2)
        return [] if s1 == s2
        return [Difference.insert(nil, s2)] if s1.nil?
        return [Difference.delete(nil, s1)] if s2.nil?
        [Difference.change(nil, s1, s2)]
      end
    end
  end
end
