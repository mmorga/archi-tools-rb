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
        org2 = org1.dup
        added_folder = build_folder
        org2.add_folder(added_folder)
        org_diffs = Context.new(org1, org2).diffs(OrganizationDiff.new)
        assert_equal [Difference.insert("Organization/folders/#{added_folder.id}", added_folder)], org_diffs
      end

      def test_org_folder_deleted
        org1 = build_organization(with_folders: 3)
        org2 = org1.dup
        added_folder = build_folder
        org1.add_folder(added_folder)
        org_diffs = Context.new(org1, org2).diffs(OrganizationDiff.new)
        assert_equal [Difference.delete("Organization/folders/#{added_folder.id}", added_folder)], org_diffs
      end

      def test_org_folder_changed
        org1 = build_organization(with_folders: 1)
        f1 = build_folder
        org1.add_folder(f1)
        org2 = org1.dup
        org2.folders[f1.id] = f1.with(name: f1.name + "changed")
        org_diffs = Context.new(org1, org2).diffs(OrganizationDiff.new)
        assert_equal [
          Difference.change("Organization/folders/#{f1.id}/name", f1.name, org2.folders[f1.id].name)
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
