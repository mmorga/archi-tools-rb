# frozen_string_literal: true
module Archimate
  module Diff
    class Conflicts
      class DeletedElementsReferencedInDiagramsConflict < BaseConflict
        def describe
          "Deleted Elements in one change set are referenced in Diagrams updated in the other"
        end

        def filter1
          ->(diff) { diff.element? && diff.delete? }
        end

        def filter2
          ->(diff) { diff.in_diagram? }
        end

        def diff_conflicts(diff1, diff2)
          diff2.model.diagrams[diff2.diagram_id].element_references.include? diff1.element_id
        end
      end
    end
  end
end
