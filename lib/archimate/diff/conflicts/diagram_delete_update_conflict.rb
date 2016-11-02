# frozen_string_literal: true
module Archimate
  module Diff
    class Conflicts
      class DiagramDeleteUpdateConflict < BaseConflict
        def describe
          "Deleted Diagrams in one change set are updated in the other"
        end

        def filter1
          -> (diff) { diff.delete? && diff.diagram? }
        end

        def filter2
          -> (diff) { diff.in_diagram? }
        end

        def diff_conflicts(diff1, diff2)
          diff1.diagram_id == diff2.diagram_id
        end
      end
    end
  end
end
