# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class Conflicts
      class DeletedElementsReferencedInDiagramsConflictTest < Minitest::Test
        def setup
          @model = build_model
          @diff = Archimate::Diff::Delete.new("Model<#{@model.id}>/name", @model, @model.name)
          @subject = DeletedElementsReferencedInDiagramsConflict.new([@diff], [])
        end

        def test_filter1
          refute @subject.filter1.call(@diff)
        end
      end
    end
  end
end
