# frozen_string_literal: true
module Archimate
  module Diff
    class IdHashDiff
      attr_reader :differ

      def initialize(differ)
        @differ = differ.new
      end

      def diffs(l1, l2)
        diff_list = []
        l1.each do |id, el|
          diff_list << @differ.diffs(el, l2[id]) if l2.include?(id) && el != l2[id]
          diff_list << Difference.delete(id, el) unless l2.include?(id)
        end
        l2.each do |id, el|
          diff_list << Difference.insert(id, el) unless l1.include?(id)
        end
        diff_list.flatten
      end
    end
  end
end
