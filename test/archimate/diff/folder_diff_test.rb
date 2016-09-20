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

      def test_folder_added
        f1 = build_folder
        f2 = f1.dup
        added_folder = build_folder
        f2.add_folder(added_folder)
        folder_diffs = Context.new(f1, f2).diffs(FolderDiff.new)
        assert_equal [Difference.insert("Folder<#{f1.id}>/folders/#{added_folder.id}", added_folder)], folder_diffs
      end

      def test_folder_deleted
        f1 = build_folder
        f2 = f1.dup
        added_folder = build_folder
        f1.add_folder(added_folder)
        folder_diffs = Context.new(f1, f2).diffs(FolderDiff.new)
        assert_equal [Difference.delete("Folder<#{f1.id}>/folders/#{added_folder.id}", added_folder)], folder_diffs
      end

      def test_folder_changed
        f1 = build_folder
        f1_1 = build_folder
        f1.add_folder(f1_1)
        f2 = f1.dup
        f2.folders[f1_1.id] = f1_1.dup(name: f1_1.name + "changed")
        folder_diffs = Context.new(f1, f2).diffs(FolderDiff.new)
        assert_equal [
          Difference.change("Folder<#{f1.id}>/folders/#{f1_1.id}/name", f1_1.name, f2.folders[f1_1.id].name)
        ], folder_diffs
      end
    end
  end
end
