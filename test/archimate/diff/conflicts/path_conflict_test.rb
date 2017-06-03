# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class Conflicts
      class PathConflictTest < Minitest::Test
        def setup
          @aio = Archimate::AIO.new(verbose: false, interactive: false)
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
          @diff_name = Archimate::Diff::Delete.new(ArchimateNodeAttributeReference.new(@model, :name))

          @diff1 = Archimate::Diff::Insert.new(ArchimateArrayReference.new(@model.relationships, 0))
          @diff2 = Archimate::Diff::Insert.new(ArchimateArrayReference.new(@model.relationships, 1))

          @subject = PathConflict.new([@diff1, @diff_name], [@diff2])
        end

        def test_two_inserted_elements_with_diff_ids_shouldnt_conflict
          refute @subject.diff_conflicts(@diff1, @diff2)
        end

        def test_two_inserts_same_path
          local = @model.with(relationships: [build_relationship.with(id: @relationship.id)])
          diff2 = Archimate::Diff::Insert.new(
            ArchimateArrayReference.new(local.relationships, 0)
          )

          refute_equal @diff1, diff2
          assert @subject.diff_conflicts(@diff1, diff2)
        end

        def test_two_inserted_documentation_nodes_should_not_conflict
          assert_empty @model.elements.first.documentation
          local = @model.with(
            elements: @model.elements
              .map { |el| el.id == @model.elements.first.id ? el.with(documentation: [build_documentation]) : el }
          )
          remote = @model.with(
            elements: @model.elements
              .map { |el| el.id == @model.elements.first.id ? el.with(documentation: [build_documentation]) : el }
          )

          diffs1 = @model.diff(local)
          diffs2 = @model.diff(remote)

          assert_equal 1, diffs1.size
          assert_equal 1, diffs2.size

          refute @subject.diff_conflicts(diffs1[0], diffs2[0])
        end
      end
    end
  end
end
