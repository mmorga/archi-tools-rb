# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class OrganizationDiffTest < Minitest::Test
      def setup
        @organization_diff = OrganizationDiff.new
      end

      def test_equivalent
        org = build_organization
        ctx = Context.new(org, org.dup)
        assert_empty @organization_diff.diffs(ctx)
      end

      def test_org_folder_added
        org1 = build_organization(with_folders: 3)
        added_folder = build_folder
        folders = org1.folders.dup
        folders[added_folder.id] = added_folder
        org2 = org1.with(folders: folders)
        org_diffs = Context.new(org1, org2).diffs(OrganizationDiff.new)
        assert_equal [Difference.insert("Organization/folders/#{added_folder.id}", added_folder)], org_diffs
      end

      def test_org_folder_deleted
        org1 = build_organization(with_folders: 3)
        deleted_folder = org1.folders[org1.folders.keys.first]
        folders2 = org1.folders.reject { |k,v| k == deleted_folder.id }
        org2 = org1.with(folders: folders2)
        org_diffs = Context.new(org1, org2).diffs(OrganizationDiff.new)
        assert_equal [Difference.delete("Organization/folders/#{deleted_folder.id}", deleted_folder)], org_diffs
      end

      def test_org_folder_changed
        org1 = build_organization(with_folders: 2)
        original_folder = org1.folders[org1.folders.keys.last]
        folders2 = org1.folders.reject { |k,v| k == original_folder.id }
        changed_folder = original_folder.with(name: original_folder.name + "changed")
        folders2[changed_folder.id] = changed_folder
        org2 = org1.with(folders: folders2)
        org_diffs = Context.new(org1, org2).diffs(OrganizationDiff.new)
        assert_equal [
          Difference.change("Organization/folders/#{original_folder.id}/name", original_folder.name, changed_folder.name)
        ], org_diffs
      end

      # Organization Test cases
      # 4. Moved Folder
      # 5. Added child
      # 6. Removed child
      # 7. Moved child
    end
  end
end
