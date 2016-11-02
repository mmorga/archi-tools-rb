# frozen_string_literal: true
module Archimate
  module Diff
    class Conflicts
      class DeletedRelationshipsReferencedInDiagramsConflict
        attr_reader :associative

        def initialize(base_local_diffs, base_remote_diffs)
          @associative = false
          @base_local_diffs = base_local_diffs
          @base_remote_diffs = base_remote_diffs
          @all_diffs = @base_local_diffs + @base_remote_diffs
        end

        def describe
          "Deleted Relationships in one change set are referenced in Diagrams updated in the other"
        end

        def filter1
        end

        def filter2
        end

        # There exists a conflict between d1 & d2 if d1 deletes a relationship that is added or part of a change referenced
        # in a d2 diagram.
        #
        # Side one filter: diffs1.delete?.relationship?
        # Side two filter: diffs2.!delete?.source_connection?
        # Check: diff2.source_connection.relationship == diff1.relationship_id
        def conflicts
          ds1 = @all_diffs.select(&:delete?).select(&:relationship?)
          ds2 = @all_diffs.reject(&:delete?).select(&:in_diagram?)
          ds1.each_with_object([]) do |d1, a|
            ds2c = ds2.select do |d2|
              d2.model.diagrams[d2.diagram_id].relationships.include? d1.relationship_id
            end
            a << Conflict.new(
              d1,
              ds2c,
              "Relationship referenced in deleted diagram"
            ) unless ds2c.empty?
          end
        end
      end
    end
  end
end
