# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Model
    class FolderTest < Minitest::Test
      def setup
        @f1 = Folder.new("123", "Sales", "Business")
        @f2 = Folder.new("123", "Sales", "Business")
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
        refute @f1 == Folder.new("234", "Sales", "Business")
      end

      def test_dup
        f_dup = @f1.dup
        [:items, :folders, :documentation, :properties].each do |sym|
          refute_equal @f1.send(sym).object_id, f_dup.send(sym).object_id, "Expected instances of #{sym} to be different"
        end
      end

      def test_build_folders_empty
        result = build_folders(0)
        assert result.is_a?(Hash)
        assert_empty(result)
      end
    end
  end
end
