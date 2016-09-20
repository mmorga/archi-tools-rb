# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Model
    class OrganizationTest < Minitest::Test
      def test_new
        folders = build_folders(3, min_items: 1, max_items: 5)
        org = Organization.new(folders)
        assert_equal folders, org.folders
      end

      def test_dup
        org1 = build_organization(with_folders: 3)
        org2 = org1.dup
        refute_equal org1.folders.object_id, org2.folders.object_id
      end

      def test_hash
        o1 = build_organization(with_folders: 3)
        o2 = o1.dup
        assert_equal o1.hash, o2.hash
      end

      def test_hash_negative_case
        o1 = build_organization(with_folders: 3)
        o2 = build_organization(with_folders: 3)
        refute_equal o1.hash, o2.hash
      end

      def test_equality_operator
        m1 = build_organization(with_items: 3)
        m2 = m1.dup
        assert_equal m1, m2
      end

      def test_build_organization
        m1 = build_organization
        assert_empty m1.folders
      end

      def test_build_organization_with_folders
        m1 = build_organization(with_folders: 3)
        assert_equal 3, m1.folders.size
      end

      def test_equality_operator_false
        m1 = build_organization(with_folders: 3)
        m2 = m1.dup
        m2.add_folder build_folder
        refute_equal m1, m2
      end

      def test_add_folder
        org = build_organization(with_folders: 3)
        folder_count = org.folders.size
        expected = build_folder
        org.add_folder(expected)
        assert_equal folder_count + 1, org.folders.size
        assert_equal expected, org.folders[expected.id]
      end
    end
  end
end
