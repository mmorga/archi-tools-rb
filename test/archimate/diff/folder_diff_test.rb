# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class FolderDiffTest < Minitest::Test
      def setup
        @folder_diff = FolderDiff.new
      end

      def test_equivalent
        folder = build_folder
        ctx = Context.new(folder, folder.dup)
        assert_empty @folder_diff.diffs(ctx)
      end

      def test_diff_name
        f1 = build_folder
        f2 = f1.dup(name: f1.name + "changed")
        folder_diffs = Context.new(f1, f2).diffs(FolderDiff.new)
        assert_equal [Difference.change("Folder<#{f1.id}>/name", f1.name, f2.name)], folder_diffs
      end

      def xtest_folder_added
        fail "Write me!"
      end

      def xtest_insert
        ctx = Context.new(nil, "hello")
        assert_equal [Difference.insert("", "hello")], @folder_diff.diffs(ctx)
      end

      def xtest_delete
        ctx = Context.new("hello", nil)
        assert_equal [Difference.delete("", "hello")], @folder_diff.diffs(ctx)
      end

      def xtest_change
        ctx = Context.new("base", "change", "test")
        assert_equal [Difference.change("test", "base", "change")], @folder_diff.diffs(ctx)
      end
    end
  end
end
