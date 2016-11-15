# frozen_string_literal: true
module Archimate
  module Diff
    class Conflicts
      # There exists a conflict between d1 & d2 if d1 deletes a relationship that is added or part of a change referenced
      # in a d2 diagram.
      #
      # Side one filter: diffs1.delete?.relationship?
      # Side two filter: diffs2.!delete?.source_connection?
      # Check: diff2.source_connection.relationship == diff1.relationship_id
      class DeletedRelationshipsReferencedInDiagramsConflict < BaseConflict
        def describe
          "Deleted Relationships in one change set are referenced in Diagrams updated in the other"
        end

        def filter1
          -> (diff) { diff.delete? && diff.relationship? }
        end

        def filter2
          -> (diff) { !diff.delete? && diff.in_diagram? }
        end

        def diff_conflicts(diff1, diff2)
          diff2.model.diagrams[diff2.diagram_idx].relationships.include?(diff1.relationship.id)
        end
      end
    end
  end
end
