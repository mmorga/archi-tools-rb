# frozen_string_literal: true
module Archimate
  module Diff
    class IdHashDiff
      attr_reader :l1, :l2

      def initialize(l1, l2)
        @l1 = l1
        @l2 = l2
      end

      def diffs
        diff_list = []
        l1.each do |id, el|
          diff_list << Archimate::Diff::Difference.change(el, l2[id], l2[id], nil, id) if l2.include?(id) && el != l2[id]
          diff_list << Archimate::Diff::Difference.delete(el, el, nil, id) unless l2.include?(id)
        end
        l2.each do |id, el|
          diff_list << Archimate::Diff::Difference.insert(el, el, nil, id) unless l1.include?(id)
        end
        diff_list
      end
    end
  end
end
