# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class FolderTest < Minitest::Test
      def setup
        @f1 = Folder.new(parent_id: nil, id: "123", name: "Sales", type: "Business", items: [], documentation: [], properties: [], folders: {})
        @f2 = Folder.new(parent_id: nil, id: "123", name: "Sales", type: "Business", items: [], documentation: [], properties: [], folders: {})
      end

      def test_new
        assert_equal "123", @f1.id
        assert_equal "Sales", @f1.name
        assert_equal "Business", @f1.type
        assert_empty @f1.folders
        assert_empty @f1.items
        assert_empty @f1.documentation
        assert_empty @f1.properties
      end

      def test_build_folders_empty
        result = build_folders(0)
        assert result.is_a?(Hash)
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

        assert_instance_of Hash, f.folders
        assert_empty f.folders
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
        refute @f1 == Folder.create(id: "234", name: "Sales", type: "Business")
      end
    end
  end
end
