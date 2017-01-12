# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class Conflicts
      class DeletedItemsReferencedConflictTest < Minitest::Test
        def setup
          @aio = Archimate::AIO.new(verbose: false, interactive: false)
        end

        def test_element_deleted_referenced_in_relationship
          model = build_model(with_elements: 1, with_relationships: 1)
          diff1 = Diff::Delete.new(Archimate.node_reference(model.lookup(model.relationships.first.source)))
          diff2 = Diff::Insert.new(Archimate.node_reference(model.relationships.first))
          subject = DeletedItemsReferencedConflict.new([diff1], [diff2], @aio)

          assert subject.diff_conflicts(diff1, diff2)
        end

        def test_diagram_attr_update_conflicts_with_deleted_child_element
          base = build_model(with_elements: 1)
          deleted_element_id = base.elements.first.id
          local = base.with(elements: [])
          remote = base.with(
            diagrams: [
              build_diagram(
                children:
                  [build_child(archimate_element: deleted_element_id)]
              )
            ]
          )

          diffs2 = base.diff(remote)
          non_folder_diffs2 = diffs2.reject { |diff| diff.target.path =~ /^folders/ }
          assert_equal 1, non_folder_diffs2.size
          diffs1 = base.diff(local)
          non_folder_diffs1 = diffs1.reject { |diff| diff.target.path =~ /^folders/ }
          assert_equal 1, non_folder_diffs1.size

          subject = DeletedItemsReferencedConflict.new(diffs1, diffs2, @aio)

          assert subject.diff_conflicts(non_folder_diffs1[0], non_folder_diffs2[0])
        end
      end
    end
  end
end
