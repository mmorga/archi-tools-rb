# frozen_string_literal: true
module Archimate
  module Diff
    class Conflicts
      # DeletedItemsReferencedConflict
      #
      # This sort of conflict occurs when one change set has deleted an element
      # that is referenced by id in the other change set.
      #
      # For example:
      #
      # In the local change set, an element with id "abc123" is deleted.
      # In the remote change set, a child is inserted into a diagram with
      # archimate_element = "abc123". These two changes are in conflict.
      class DeletedItemsReferencedConflict < BaseConflict
        using DataModel::DiffableArray
        using DataModel::DiffablePrimitive

        def describe
          "Deleted items in one change set are referenced in the other change set"
        end

        # Filters a changeset to potentially conflicting diffs (making the set
        # of combinations to check smaller)
        #
        # @return [lambda] a filter to limit diffs to Delete type
        def filter1
          ->(diff) { diff.delete? && diff.target.value.is_a?(DataModel::IdentifiedNode) }
        end

        # Filters a changeset to potentially conflicting diffs (making the set
        # of combinations to check smaller)
        #
        # @return [lambda] a filter to limit diffs to other
        #   than Delete type
        def filter2
          ->(diff) { !diff.delete? }
        end

        # Determine the set of conflicts between the given diffs
        # def conflicts
        #   progressbar = @aio.create_progressbar(total: diff_iterations.size)
        #   diff_iterations.each_with_object([]) do |(md1, md2), a|
        #     progressbar.increment
        #     a.concat(
        #       md1.map { |diff1| [diff1, md2.select(&method(:diff_conflicts).curry[diff1])] }
        #         .reject { |_diff1, diff2| diff2.empty? }
        #         .map { |diff1, diff2_ary| Conflict.new(diff1, diff2_ary, describe) }
        #     )
        #   end
        # ensure
        #   progressbar&.finish
        # end

        # TODO: This is simple, but might be slow. If it is, then override
        # the conflicts method to prevent calculating referenced_identified_nodes methods
        def diff_conflicts(diff1, diff2)
          diff2.target.value.referenced_identified_nodes.include?(diff1.target.value.id)
        end
      end
    end
  end
end
