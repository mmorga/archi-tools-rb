# frozen_string_literal: true
module Archimate
  module Diff
    class Conflicts
      class DeletedElementsReferencedInRelationshipsConflict
        attr_reader :associative

        def initialize(base_local_diffs, base_remote_diffs)
          @associative = false
          @base_local_diffs = base_local_diffs
          @base_remote_diffs = base_remote_diffs
          @all_diffs = @base_local_diffs + @base_remote_diffs
        end

        def describe
          "Deleted Elements in one change set are referenced in Relationships updated in the other"
        end

        def filter1
        end

        def filter2
        end

        # There exists a conflict if a relationship is added (or changed?) on one side that references an
        # element that is deleted on the other side.
        #
        # Side one filter: diffs1.insert?.relationship? map(:source, :target)
        # Side two filter: diffs2.delete?.element? map(:element_id)
        # Check diffs1.source == element_id or diffs1.target == element_id
        def conflicts
          ds1 = @all_diffs.reject(&:delete?).select(&:relationship?)
          ds2 = @all_diffs.select(&:delete?).select(&:element?)
          ds1.each_with_object([]) do |d1, a|
            rel = d1.relationship
            rel_el_ids = [rel.source, rel.target]
            ds2_conflicts = ds2.select { |d2| rel_el_ids.include?(d2.element_id) }
            a << Conflict.new(
              d1,
              ds2_conflicts,
              "Added/updated relationship references in deleted element"
            ) unless ds2_conflicts.empty?
          end
        end
      end
    end
  end
end
