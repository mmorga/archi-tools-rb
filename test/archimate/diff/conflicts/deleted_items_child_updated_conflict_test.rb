# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class Conflicts
      class DeletedItemsChildUpdatedConflictTest < Minitest::Test
        def setup
          skip("Diff re-write")
          @model = build_model(
            elements: [
              build_element(documentation: build_documentation)
            ]
          )

          @diff1 = Diff::Delete.new(ArchimateArrayReference.new(@model.elements, 0))
          @diff2 = Diff::Insert.new(ArchimateArrayReference.new(@model.elements[0].documentation, 0))
          @subject = DeletedItemsChildUpdatedConflict.new([@diff1], [@diff2])
        end

        def test_describe
          skip("Diff re-write")
          assert_kind_of String, @subject.describe
        end

        def test_filter1
          skip("Diff re-write")
          assert @subject.filter1.call(@diff1)
          refute @subject.filter1.call(@diff2)
        end

        def test_filter2
          skip("Diff re-write")
          assert @subject.filter2.call(@diff2)
          refute @subject.filter2.call(@diff1)
        end

        def test_element_deleted_referenced_in_relationship
          skip("Diff re-write")
          assert @subject.diff_conflicts(@diff1, @diff2)
        end

        def test_diffs_at_same_path_shouldnt_conflict
          skip("Diff re-write")
          refute @subject.diff_conflicts(@diff1, @diff1)
        end
      end
    end
  end
end
