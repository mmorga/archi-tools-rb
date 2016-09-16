# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Model
    class FolderTest < Minitest::Test
      def setup
        @b1 = Folder.new(0, 10, 500, 700)
        @b2 = Folder.new(0, 10, 500, 700)
      end

      def xtest_new
        assert_equal 0, @b1.x
        assert_equal 10, @b1.y
        assert_equal 500, @b1.width
        assert_equal 700, @b1.height
      end

      def xtest_hash
        assert_equal @b1.hash, @b2.hash
      end

      def xtest_hash_diff
        refute_equal @b1.hash, build_bounds.hash
      end

      def xtest_operator_eqleql_true
        assert @b1 == @b2
      end

      def xtest_operator_eqleql_false
        refute @b1 == build_bounds
      end
    end
  end
end
