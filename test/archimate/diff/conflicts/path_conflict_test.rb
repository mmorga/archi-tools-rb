# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class Conflicts
      class PathConflictTest < Minitest::Test
        def setup
          elements = build_element_list(with_elements: 2)
          relationships = build_relationship_list(
            with_relationships: 2,
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
          @relationship = @model.relationships.first
          @relationship2 = @model.relationships[1]
          @diff_name = Archimate::Diff::Delete.new(Archimate.node_reference(@model, "name"))

          @diff1 = Archimate::Diff::Insert.new(Archimate.node_reference(@relationship))
          @diff2 = Archimate::Diff::Insert.new(Archimate.node_reference(@relationship2))

          @subject = PathConflict.new([@diff1, @diff_name], [@diff2])
        end

        def test_two_inserted_elements_with_diff_ids_shouldnt_conflict
          refute @subject.diff_conflicts(@diff1, @diff2)
        end

        def test_two_inserts_same_path
          local = @model.with(relationships: [build_relationship.with(id: @relationship.id)])
          diff2 = Archimate::Diff::Insert.new(
            Archimate.node_reference(
              local.relationships.first
            )
          )

          refute_equal @diff1, diff2
          assert @subject.diff_conflicts(@diff1, diff2)
        end
      end
    end
  end
end
