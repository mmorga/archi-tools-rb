# frozen_string_literal: true
module Archimate
  module Diff
    class Change < Difference
      using DataModel::DiffableArray

      # Create a new Change difference
      #
      # @param from_element [Archimate::DataModel::DiffableStruct] Element that was changed
      # @param to_element [Archimate::DataModel::DiffableStruct] Element that was changed to
      # @param sub_path [str] Path under from_element/to_element for primitive values
      def initialize(from_element, to_element, sub_path = "")
        super
      end

      def to_s
        "#{diff_type} #{what(to_element)} in #{from} to #{to_value}"
      end

      def apply(el)
        el.change(sub_path, from_value, to_value)
      end

      private

      def diff_type
        HighLine.color('CHANGE:', :change)
      end
    end
  end
end
