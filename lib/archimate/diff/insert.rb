# frozen_string_literal: true
module Archimate
  module Diff
    class Insert < Difference
      using DataModel::DiffableArray

      # Create a new Insert difference
      #
      # @param inserted_element [Archimate::DataModel::ArchimateNode] Element
      #   that was inserted
      # @param sub_path [str] Path under inserted_element for primitive values
      def initialize(target)
        super
      end

      def to_s
        # Note - the explicit to_s is required to access the DiffableArray
        #        implementation if the parent is an Array.
        "#{diff_type} #{target} into #{target.parent.to_s}"
      end

      def apply(to_model)
        throw TypeError, "Expected a Archimate::DataModel::Model, was a #{to_model.class}" unless to_model.is_a?(DataModel::Model)
        target.insert(to_model)
        to_model
      end

      def insert?
        true
      end

      private

      def diff_type
        HighLine.color('INSERT:', :insert)
      end
    end
  end
end
