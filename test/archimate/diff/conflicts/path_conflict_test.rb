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
          @diff_name = Archimate::Diff::Delete.new("Model<#{@model.id}>/name", @model, @model.name)

          @diff1 = Archimate::Diff::Insert.new("Model<#{@model.id}>/relationships/#{@relationship.id}", @model, @relationship)
          @diff2 = Archimate::Diff::Insert.new("Model<#{@model.id}>/relationships/#{@relationship.id}", @model, @relationship2)

          @subject = PathConflict.new([@diff1, @diff_name], [@diff2])
        end

        def test_conflict
          assert @subject.diff_conflicts(@diff1, @diff2)
        end
      end
    end
  end
end
