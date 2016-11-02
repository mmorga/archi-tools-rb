# frozen_string_literal: true
module Archimate
  module Diff
    class Conflicts
      class DiagramDeleteUpdateConflict
        attr_reader :associative

        def initialize(base_local_diffs, base_remote_diffs)
          @associative = false
          @base_local_diffs = base_local_diffs
          @base_remote_diffs = base_remote_diffs
        end

        def describe
          "Deleted Diagrams in one change set are updated in the other"
        end

        def filter1
          ->(diff) { !diff.delete? && diff.diagram? }
        end

        def filter2
          ->(diff) { diff.in_diagram? }
        end

        # Returns the set of conflicts caused by one diff set deleting a diagram
        # that the other diff set shows updated. This means that the diagram
        # probably shouldn't be deleted.
        def conflicts
          [@base_local_diffs, @base_remote_diffs].permutation(2).each_with_object([]) do |(diffs1, diffs2), a|
            a.concat(
              diagram_diffs_in_conflict(
                diagram_deleted_diffs(diffs1),
                diagram_updated_diffs(diffs2)
              )
            )
          end
        end

        # we want to make a Conflict for each parent_diff and set of child_diffs with the same diagram_id
        def diagram_diffs_in_conflict(parent_diffs, child_diffs)
          parent_diffs.each_with_object([]) do |parent_diff, a|
            conflicting_child_diffs = child_diffs.select { |child_diff| parent_diff.diagram_id == child_diff.diagram_id }
            a << Conflict.new(
              # TODO: we need a context here to know if it's a base to remote or remote to base conflict
              parent_diff, conflicting_child_diffs, "Diagram deleted in one change set modified in another"
            ) unless conflicting_child_diffs.empty?
          end
        end

        def diagram_deleted_diffs(diffs)
          diffs.select { |i| i.is_a?(Delete) && i.diagram? }
        end

        def diagram_updated_diffs(diffs)
          diffs.select(&:in_diagram?)
        end
      end
    end
  end
end
