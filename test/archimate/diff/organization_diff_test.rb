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

      # Organization Test cases
      # 1. Added Folder
      # 2. Removed Folder
      # 3. Renamed Folder
      # 4. Moved Folder
      # 5. Added child
      # 6. Removed child
      # 7. Moved child
      def xtest_organization_folder_added
        fail "Write me!"
      end

      def xtest_insert
        ctx = Context.new(nil, "hello")
        assert_equal [Difference.insert("", "hello")], @organization_diff.diffs(ctx)
      end

      def xtest_delete
        ctx = Context.new("hello", nil)
        assert_equal [Difference.delete("", "hello")], @organization_diff.diffs(ctx)
      end

      def xtest_change
        ctx = Context.new("base", "change", "test")
        assert_equal [Difference.change("test", "base", "change")], @organization_diff.diffs(ctx)
      end
    end
  end
end
