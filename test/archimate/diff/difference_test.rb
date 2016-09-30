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
    end
  end
end
