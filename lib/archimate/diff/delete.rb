# frozen_string_literal: true
module Archimate
  module Diff
    class Delete < Difference
      using DataModel::DiffableArray

      # Create a new Delete difference
      #
      # @param deleted_element [Archimate::DataModel::DiffableStruct] Element that was deleted
      # @param sub_path [str] Path under deleted_element for primitive values
      def initialize(deleted_element, sub_path = "")
        super(deleted_element, nil, sub_path)
      end

      def to_s
        "#{diff_type} #{what(from_element)} from #{from}"
      end

      def apply(el)
        el.delete(sub_path, from_value)
      end

      private

      def diff_type
        HighLine.color('DELETE:', :delete)
      end
    end
  end
end
