# frozen_string_literal: true
module Archimate
  module Diff
    class Conflicts
      # There exists a conflict if a relationship is added (or changed?) on one side that references an
      # element that is deleted on the other side.
      #
      # Side one filter: diffs1.insert?.relationship? map(:source, :target)
      # Side two filter: diffs2.delete?.element? map(:element_id)
      # Check diffs1.source == element_id or diffs1.target == element_id
      class DeletedElementsReferencedInRelationshipsConflict < BaseConflict
        def describe
          "Deleted Elements in one change set are referenced in Relationships updated in the other"
        end

        def filter1
          -> (diff) { !diff.delete? && diff.relationship? }
        end

        def filter2
          -> (diff) { diff.delete? && diff.element? }
        end

        def diff_conflicts(diff1, diff2)
          rel = diff1.relationship
          rel_el_ids = [rel.source, rel.target]
          rel_el_ids.include?(diff2.element_id)
        end
      end
    end
  end
end
