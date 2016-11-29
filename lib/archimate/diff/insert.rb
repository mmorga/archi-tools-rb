# frozen_string_literal: true
module Archimate
  module Diff
    class Insert < Difference
      using DataModel::DiffableArray

      # Create a new Insert difference
      #
      # @param inserted_element [Archimate::DataModel::DiffableStruct] Element
      #   that was inserted
      # @param sub_path [str] Path under inserted_element for primitive values
      def initialize(inserted_element, sub_path = "")
        super(nil, inserted_element, sub_path.to_s)
      end

      def to_s
        "#{diff_type} #{what(to_element)} into #{to}"
      end

      def apply(el)
        puts path.pretty_inspect
        el.insert(sub_path, to_value)
      end

      private

      def diff_type
        HighLine.color('INSERT:', :insert)
      end
    end
  end
end
