# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class Conflicts
      class DeletedElementsReferencedInDiagramsConflictTest < Minitest::Test
        def setup
          elements = build_element_list(with_elements: 2)
          relationships = build_relationship_list(
            with_relationships: 1,
            elements: elements
          )
          @model = build_model(
            elements: elements,
            diagrams: build_diagram_list(
              with_diagrams: 1,
              elements: elements,
              relationships: relationships
            ),
            relationships: relationships
          )

          @element = @model.elements.first
          @diagram = @model.diagrams.first
          @diff_name = Archimate::Diff::Delete.new(@model, "name")
          @diff1 = Archimate::Diff::Delete.new(@model.elements[0])
          @diff2 = Archimate::Diff::Insert.new(@model.diagrams[0], "name")
          @diff3 = Archimate::Diff::Delete.new(@model.diagrams[0].children[0])
          @subject = DeletedElementsReferencedInDiagramsConflict.new([@diff_name, @diff1], [@diff3])
        end

        def test_filter1
          assert @subject.filter1.call(@diff1)
          refute @subject.filter1.call(@diff_name)
        end

        def test_filter2
          assert @subject.filter2.call(@diff2)
          refute @subject.filter2.call(@diff_name)
          refute @subject.filter2.call(@diff3)
        end

        def test_diff_conflicts_diffs_in_conflict
          assert @subject.diff_conflicts(@diff1, @diff2)
        end

        def test_diff_conflicts_diffs_not_in_conflict
          refute @subject.diff_conflicts(@diff1, @diff_name)
          refute @subject.diff_conflicts(@diff2, @diff1)
        end
      end
    end
  end
end
