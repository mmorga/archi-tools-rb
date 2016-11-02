# frozen_string_literal: true
module Archimate
  module Diff
    class Conflicts
      class DeletedElementsReferencedInDiagramsConflict
        attr_reader :associative

        def initialize(base_local_diffs, base_remote_diffs)
          @associative = false
          @base_local_diffs = base_local_diffs
          @base_remote_diffs = base_remote_diffs
        end

        def describe
          "Deleted Elements in one change set are referenced in Diagrams updated in the other"
        end

        def filter1
        end

        def filter2
        end

        def conflicts
          [@base_local_diffs, @base_remote_diffs].permutation(2).each_with_object([]) do |(md1, md2), a|
            md2_diagram_diffs = md2.select(&:in_diagram?)
            a.concat(
              md1.select { |d| d.element? && d.is_a?(Delete) }.each_with_object([]) do |md1_diff, conflicts|
                conflicting_md2_diffs = md2_diagram_diffs.select do |md2_diff|
                  md2_diff.model.diagrams[md2_diff.diagram_id].element_references.include? md1_diff.element_id
                end
                conflicts << Conflict.new(md1_diff,
                                          conflicting_md2_diffs,
                                          "Elements referenced in deleted diagram") unless conflicting_md2_diffs.empty?
              end
            )
          end
        end
      end
    end
  end
end
