# frozen_string_literal: true
module Archimate
  module Diff
    class Change < Difference
      using DataModel::DiffableArray

      # Create a new Change difference
      #
      # @param from_element [Archimate::DataModel::ArchimateNode] Element that was changed
      # @param to_element [Archimate::DataModel::ArchimateNode] Element that was changed to
      # @param sub_path [str] Path under from_element/to_element for primitive values
      def initialize(to_element, from_element)
        super(to_element, from_element)
      end

      def to_s
        # Note - the explicit to_s is required to access the DiffableArray
        #        implementation if the parent is an Array.
        "#{diff_type} #{target} in #{changed_from.parent.to_s} to #{target.value}"
      end

      def apply(to_model)
        throw TypeError, "Expected a Archimate::DataModel::Model, was a #{to_model.class}" unless to_model.is_a?(DataModel::Model)
        target.change(to_model)
        to_model
      end

      def change?
        true
      end

      private

      def diff_type
        HighLine.color('CHANGE:', :change)
      end
    end
  end
end
