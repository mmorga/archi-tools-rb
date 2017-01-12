# frozen_string_literal: true
module Archimate
  module Diff
    class Move < Difference
      using DataModel::DiffablePrimitive
      using DataModel::DiffableArray

      # Create a new Move difference
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
        "#{diff_type} #{changed_from.parent&.to_s} #{HighLine.color(target.to_s, :change)} moved to #{target.array_index}"
      end

      # TODO: patch is a better name than apply
      def apply(to_model)
        throw(
          TypeError,
          "Expected a Archimate::DataModel::Model, was a #{to_model.class}"
        ) unless to_model.is_a?(DataModel::Model)
        target.move(to_model, changed_from)
        to_model
      end

      def move?
        true
      end

      def kind
        "Move"
      end

      private

      def diff_type
        HighLine.color('MOVE:', :move)
      end
    end
  end
end
