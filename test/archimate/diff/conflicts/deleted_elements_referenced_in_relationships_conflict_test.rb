# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class Conflicts
      class DeletedElementsReferencedInRelationshipsConflictTest < Minitest::Test
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
            relationships: relationships.values
          )

          @element = @model.elements.values.first
          @relationship = @model.relationships.values.first
          @diff_name = Archimate::Diff::Delete.new("Model<#{@model.id}>/name", @model, @model.name)
          @diff1 = Archimate::Diff::Insert.new("Model<#{@model.id}>/relationships/#{@relationship.id}", @model, @relationship)
          @diff2 = Archimate::Diff::Delete.new("Model<#{@model.id}>/elements/#{@element.id}", @model, @element)
          @subject = DeletedElementsReferencedInRelationshipsConflict.new([@diff_name, @diff1], [])
        end

        def test_filter1
          refute @subject.filter1.call(@diff_name)
          assert @subject.filter1.call(@diff1)
        end

        def test_filter2
          refute @subject.filter2.call(@diff_name)
          assert @subject.filter2.call(@diff2)
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
