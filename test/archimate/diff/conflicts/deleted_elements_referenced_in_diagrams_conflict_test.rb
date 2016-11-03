# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class Conflicts
      class DeletedElementsReferencedInDiagramsConflictTest < Minitest::Test
        def setup
          @model = build_model(with_elements: 3, with_diagrams: 1)
          @element = @model.elements.values.first
          @diagram = @model.diagrams.values.first
          @diff_name = Archimate::Diff::Delete.new("Model<#{@model.id}>/name", @model, @model.name)
          @diff_del_element = Archimate::Diff::Delete.new("Model<#{@model.id}>/elements/#{@element.id}", @model, @element)
          @diff_in_diagram = Archimate::Diff::Insert.new("Model<#{@model.id}>/diagrams/#{@diagram.id}/name", @model, @diagram.name)
          @subject = DeletedElementsReferencedInDiagramsConflict.new([@diff_name, @diff_del_element], [])
        end

        def test_filter1
          refute @subject.filter1.call(@diff_name)
          assert @subject.filter1.call(@diff_del_element)
        end

        def test_filter2
          refute @subject.filter2.call(@diff_name)
          assert @subject.filter2.call(@diff_in_diagram)
        end
      end
    end
  end
end
