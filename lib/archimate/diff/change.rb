# frozen_string_literal: true
module Archimate
  module Diff
    class Change < Difference
      using DataModel::DiffableArray

      # Create a new Change difference
      #
      # @param target [Archimate::Diff::ArchimateNodeReference] reference to
      #   ArchimateNode that was changed
      # @param changed_from [Archimate::Diff::ArchimateNodeReference] Element
      #   that was changed
      def initialize(target, changed_from)
        super(target, changed_from)
      end

      def to_s
        # Note - the explicit to_s is required to access the DiffableArray
        #        implementation if the parent is an Array.
        "#{diff_type} #{changed_from.parent&.to_s} #{HighLine.color(target.to_s, :change)} changed to #{target.value}"
      end

      def apply(to_model)
        throw(
          TypeError,
          "Expected a Archimate::DataModel::Model, was a #{to_model.class}"
        ) unless to_model.is_a?(DataModel::Model)
        target.change(to_model, changed_from.value)
        to_model
      end

      def change?
        true
      end

      def kind
        "Change"
      end

      private

      def diff_type
        HighLine.color('CHANGE:', :change)
      end
    end
  end
end
