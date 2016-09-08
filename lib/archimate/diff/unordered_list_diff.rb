# frozen_string_literal: true
module Archimate
  module Diff
    class UnorderedListDiff
      attr_reader :l1, :l2

      def initialize(l1, l2)
        @l1 = l1
        @l2 = l2
      end

      def diffs
        diff_list = []
        l1.each_with_index do |item, idx|
          diff_list << Archimate::Diff::Difference.delete(item) { |d| d.index = idx } unless l2.include?(item)
        end
        l2.each_with_index do |item, idx|
          diff_list << Archimate::Diff::Difference.insert(item) { |d| d.index = idx } unless l1.include?(item)
        end
        diff_list
      end
    end
  end
end
