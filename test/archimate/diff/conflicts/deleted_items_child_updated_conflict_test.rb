# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class Conflicts
      class DeletedItemsChildUpdatedConflictTest < Minitest::Test
        def setup
          @aio = Archimate::AIO.new(verbose: false, interactive: false)
          @model = build_model(
            elements: [
              build_element(
                documentation: [
                  build_documentation
                ]
              )
            ]
          )

          @diff1 = Diff::Delete.new(Archimate.node_reference(@model.elements, 0))
          @diff2 = Diff::Insert.new(Archimate.node_reference(@model.elements.first.documentation, 0))
          @subject = DeletedItemsChildUpdatedConflict.new([@diff1], [@diff2], @aio)
        end

        def test_describe
          assert_kind_of String, @subject.describe
        end

        def test_filter1
          assert @subject.filter1.call(@diff1)
          refute @subject.filter1.call(@diff2)
        end

        def test_filter2
          assert @subject.filter2.call(@diff2)
          refute @subject.filter2.call(@diff1)
        end

        def test_element_deleted_referenced_in_relationship
          assert @subject.diff_conflicts(@diff1, @diff2)
        end

        def test_diffs_at_same_path_shouldnt_conflict
          refute @subject.diff_conflicts(@diff1, @diff1)
        end
      end
    end
  end
end
