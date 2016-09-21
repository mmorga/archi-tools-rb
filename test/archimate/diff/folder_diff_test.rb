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
        f2 = f1.with(name: f1.name + "changed")
        folder_diffs = Context.new(f1, f2).diffs(FolderDiff.new)
        assert_equal [Difference.change("Folder<#{f1.id}>/name", f1.name, f2.name)], folder_diffs
      end

      def test_folder_added
        f1 = build_folder
        added_folder = build_folder
        folders = f1.folders.dup
        folders[added_folder.id] = added_folder
        f2 = f1.with(folders: folders)
        folder_diffs = Context.new(f1, f2).diffs(FolderDiff.new)
        assert_equal [Difference.insert("Folder<#{f1.id}>/folders/#{added_folder.id}", added_folder)], folder_diffs
      end

      def test_folder_deleted
        f2 = build_folder
        added_folder = build_folder
        folders = f2.folders.dup
        folders[added_folder.id] = added_folder
        f1 = f2.with(folders: folders)
        folder_diffs = Context.new(f1, f2).diffs(FolderDiff.new)
        assert_equal [Difference.delete("Folder<#{f1.id}>/folders/#{added_folder.id}", added_folder)], folder_diffs
      end

      def test_folder_changed
        f1_1 = build_folder
        f1 = build_folder(folders: Archimate.array_to_id_hash(Array(f1_1)))
        folders = f1.folders.dup
        folders[f1_1.id] = f1_1.with(name: f1_1.name + "changed")
        f2 = f1.with(folders: folders)
        folder_diffs = Context.new(f1, f2).diffs(FolderDiff.new)
        assert_equal [
          Difference.change("Folder<#{f1.id}>/folders/#{f1_1.id}/name", f1_1.name, f2.folders[f1_1.id].name)
        ], folder_diffs
      end
    end
  end
end
