# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class DifferenceTest < Minitest::Test
      def test_delete
        change = Difference.delete(0, "Something")
        assert_equal :delete, change.kind
        assert_equal "Something", change.from
        assert_equal 0, change.entity
      end

      def test_insert
        d = Difference.insert(:model, "to_val")
        assert_equal :model, d.entity
        assert_equal "to_val", d.to
      end

      def test_context
        d = Difference.context(:model)
        assert_equal :model, d.entity
      end

      def test_apply
        context = Difference.context(:model)
        diffs = [
          Difference.delete(0, "I'm deleted"),
          Difference.insert("I'm inserted", "bogus")
        ]
        context.apply(diffs).each do |d|
          assert_equal :model, d.entity
        end
      end

      def test_insert?
        diff = Difference.insert("Added", "test")
        assert diff.insert?
        refute diff.delete?
        refute diff.change?
      end

      def test_delete?
        diff = Difference.delete("Deleted", "test")
        assert diff.delete?
        refute diff.insert?
        refute diff.change?
      end

      def test_change?
        diff = Difference.change("Change", "old and busted", "new hotness")
        assert diff.change?
        refute diff.insert?
        refute diff.delete?
      end

      def test_to_s
        diff = Difference.change("Change", "old and busted", "new hotness")
        assert_equal "CHANGE: Change: old and busted -> new hotness", HighLine.uncolor(diff.to_s)
      end

      def test_fmt_kind
        diff = Difference.change("Change", "old and busted", "new hotness")
        assert_equal "CHANGE: ", HighLine.uncolor(diff.fmt_kind)
        diff = Difference.insert(:model, "to_val")
        assert_equal "INSERT: ", HighLine.uncolor(diff.fmt_kind)
        diff = Difference.delete(:model, "deleted")
        assert_equal "DELETE: ", HighLine.uncolor(diff.fmt_kind)
      end

      def test_diff_description_change
        diff = Difference.change("Change", "old and busted", "new hotness")
        assert_equal "old and busted -> new hotness", diff.diff_description
      end

      def test_diff_description_insert
        diff = Difference.insert(:model, "to_val")
        assert_equal "to_val", diff.diff_description
      end

      def test_diff_description_delete
        diff = Difference.delete(:model, "deleted")
        assert_equal "deleted", diff.diff_description
      end

      def test_with
        diff = Difference.change("Model<abcd1234>/elements/1234abcd/label", "Old Label", "New Label")
        actual = diff.with(entity: "elements/1234abcd/label")
        assert_equal "elements/1234abcd/label", actual.entity
        refute_equal diff.entity, actual.entity
        assert_equal "Old Label", actual.from
        assert_equal "New Label", actual.to
      end

      def test_diagram?
        ["Model<abcd1234>/diagrams/1234abcd",
         "Model<3ada020a>/diagrams/1d371383"].each do |entity|
          diff = Difference.change(entity, "Old Label", "New Label")
          assert diff.diagram?
        end
      end

      def test_diagram_fail_cases
        ["Model<abcd1234>/elements/1234abcd/label"].each do |entity|
          diff = Difference.change(entity, "Old Label", "New Label")
          refute diff.diagram?
        end
      end

      def test_in_diagram?
        ["Model<abcd1234>/diagrams/1234abcd/name"].each do |entity|
          diff = Difference.change(entity, "Old Label", "New Label")
          assert diff.in_diagram?
        end
      end

      def test_diagram_id
        [
          Difference.insert("Model<abcd1234>/diagrams/1234abcd/children/726381", "new"),
          Difference.change("Model<abcd1234>/diagrams/1234abcd", "old", "new"),
          Difference.delete("Model<abcd1234>/diagrams/1234abcd/children/3439023/source_connection/384793837", "old")
        ].each do |diff|
          assert_equal "1234abcd", diff.diagram_id, "Expected to find diagram id for #{diff.entity}"
        end

        [
          Difference.change("Model<abcd1234>/label", "old", "new"),
          Difference.change("Model<abcd1234>/elements/837483723/label", "old", "new")
        ].each do |diff|
          assert_nil diff.diagram_id, "Expected to not find diagram id for #{diff.entity}"
        end
      end

      def test_in_diagram_fail_cases
        ["Model<abcd1234>/elements/1234abcd/label"].each do |entity|
          diff = Difference.change(entity, "Old Label", "New Label")
          refute diff.in_diagram?
        end
      end

      def test_diagram_differences
        diffs = [
          Difference.change("Model<abcd1234>/label", "old", "new"),
          Difference.change("Model<abcd1234>/diagrams/1234abcd", "old", "new"),
          Difference.change("Model<abcd1234>/elements/837483723/label", "old", "new"),
          Difference.insert("Model<abcd1234>/diagrams/1234abcd/children/726381", "new"),
          Difference.delete("Model<abcd1234>/diagrams/1234abcd/children/3439023/source_connection/384793837", "old")
        ]
        assert 3, Difference.diagram_differences(diffs).size
      end

      def test_diagram_deleted_diffs
        diffs = [
          Difference.change("Model<abcd1234>/label", "old", "new"),
          Difference.change("Model<abcd1234>diagrams/1234abcd", "old", "new"),
          Difference.change("Model<abcd1234>/elements/837483723/label", "old", "new"),
          Difference.insert("Model<abcd1234>diagrams/1234abcd/children/726381", "new"),
          Difference.delete("Model<abcd1234>diagrams/1234abcd/children/3439023/source_connection/384793837", "old"),
        ]
        assert 1, Difference.diagram_deleted_diffs(diffs).size
      end

      def test_diagram_updated_diffs
        diffs = [
          Difference.change("Model<abcd1234>/label", "old", "new"),
          Difference.change("Model<abcd1234>diagrams/1234abcd", "old", "new"),
          Difference.change("Model<abcd1234>/elements/837483723/label", "old", "new"),
          Difference.insert("Model<abcd1234>diagrams/1234abcd/children/726381", "new"),
          Difference.delete("Model<abcd1234>diagrams/1234abcd/children/3439023/source_connection/384793837", "old"),
        ]
        assert 2, Difference.diagram_deleted_diffs(diffs).size
      end
    end
  end
end
