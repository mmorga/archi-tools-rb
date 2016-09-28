# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class OrganizationTest < Minitest::Test
      def test_new
        folders = build_folders(3, min_items: 1, max_items: 5)
        org = Organization.new(folders: folders)
        assert_equal folders, org.folders
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
        m2 = m1.with(folders: Archimate.array_to_id_hash(build_folder))
        refute_equal m1, m2
      end

      def test_add_folder
        org = build_organization(with_folders: 3)
        folders = org.folders.dup
        expected = build_folder
        folders[expected.id] = expected
        org2 = org.with(folders: folders)
        assert_equal org.folders.size + 1, org2.folders.size
        assert_equal expected, org2.folders[expected.id]
      end
    end
  end
end
