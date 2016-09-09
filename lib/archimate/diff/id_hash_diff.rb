# frozen_string_literal: true
module Archimate
  module Diff
    class IdHashDiff
      attr_reader :l1, :l2, :differ

      def initialize(differ, l1, l2)
        @l1 = l1
        @l2 = l2
        @differ = differ
      end

      def diffs
        diff_list = []
        l1.each do |id, el|
          diff_list << @differ.new(el, l2[id]).diffs if l2.include?(id) && el != l2[id]
          diff_list << Difference.delete(el, el, nil, id) unless l2.include?(id)
        end
        l2.each do |id, el|
          diff_list << Difference.insert(el, el, nil, id) unless l1.include?(id)
        end
        diff_list.flatten
      end
    end
  end
end
