# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class FolderTest < Minitest::Test
      def setup
        @parent_id = build_id
        @child_folders = build_folder_list(with_folders: 3)
        @f1 = build_folder(parent_id: @parent_id, id: "123", name: "Sales", type: "Business", folders: @child_folders)
        @f2 = build_folder(parent_id: @parent_id, id: "123", name: "Sales", type: "Business", folders: @child_folders)
      end

      def test_new
        assert_equal "123", @f1.id
        assert_equal "Sales", @f1.name
        assert_equal "Business", @f1.type
        assert_equal @child_folders, @f1.folders
        assert_empty @f1.items
        assert_empty @f1.documentation
        assert_empty @f1.properties
      end

      def test_build_folders_empty
        result = build_folder_list(with_folders: 0)
        assert result.is_a?(Array)
        assert_empty(result)
      end

      def test_build_folder
        f = build_folder
        [:id, :name, :type].each do |sym|
          assert_instance_of String, f.send(sym)
          refute_empty f.send(sym)
        end
        [:documentation, :properties, :items].each do |sym|
          assert_instance_of Array, f.send(sym)
          assert_empty f.send(sym)
        end

        assert_instance_of Array, f.folders
        assert_empty f.folders
      end

      def test_clone
        fclone = @f1.clone
        assert_equal @f1, fclone
        refute_equal @f1.object_id, fclone.object_id
      end

      def test_hash
        assert_equal @f1.hash, @f2.hash
      end

      def test_hash_diff
        refute_equal @f1.hash, build_bounds.hash
      end

      def test_operator_eqleql_true
        assert @f1 == @f2
      end

      def test_operator_eqleql_false
        refute @f1 == Folder.create(parent_id: @parent_id, id: "234", name: "Sales", type: "Business")
      end

      def test_to_s
        assert_match "Folder", @f1.to_s
        assert_match @f1.name, @f1.to_s
      end
    end
  end
end
