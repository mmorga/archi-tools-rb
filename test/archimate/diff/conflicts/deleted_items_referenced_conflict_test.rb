# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class Conflicts
      class DeletedItemsReferencedConflictTest < Minitest::Test
        def test_element_deleted_referenced_in_relationship
          model = build_model(with_elements: 1, with_relationships: 1)
          diff1 = Diff::Delete.new(Archimate.node_reference(model.lookup(model.relationships.first.source)))
          diff2 = Diff::Insert.new(Archimate.node_reference(model.relationships.first))
          subject = DeletedItemsReferencedConflict.new([diff1], [diff2])

          assert subject.diff_conflicts(diff1, diff2)
        end

        def test_diagram_attr_update_conflicts_with_deleted_child_element
          base = build_model(with_relationships: 2, with_diagrams: 1)
          diagram = base.diagrams.first
          child = diagram.children.first

          # update diagram that references child
          remote = base.with(
            diagrams: base.diagrams.map do |i|
              diagram.id == i.id ? i.with(name: "I wuz renamed") : i
            end
          )
          diffs2 = base.diff(remote)
          assert_equal 1, diffs2.size
          # delete element from local
          local = base.with(
            elements: base.elements.reject { |e| e.id == child.archimate_element }
          )
          diffs1 = base.diff(local)
          assert_equal 1, diffs1.size

          subject = DeletedItemsReferencedConflict.new(diffs1, diffs2)

          assert subject.diff_conflicts(diffs1[0], diffs2[0])
        end
      end
    end
  end
end
