# frozen_string_literal: true
module Archimate
  module Diff
    class UnorderedListDiff
      def diffs(ctx)
        l1 = ctx.model1
        l2 = ctx.model2
        diff_list = []
        l1.each_with_index do |item, idx|
          diff_list << Difference.delete(idx, item) unless l2.include?(item)
        end
        l2.each_with_index do |item, idx|
          diff_list << Difference.insert(idx, item) { |d| d.entity = idx } unless l1.include?(item)
        end
        diff_list
      end
    end
  end
end
