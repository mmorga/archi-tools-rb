# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class ConflictTest < Minitest::Test
      def setup
        skip("Diff re-write")
        @base_local_diffs = build_diff_list
        @base_remote_diffs = build_diff_list
        @reason = "Just don't like the look of 'em"

        @subject = Conflict.new(@base_local_diffs, @base_remote_diffs, @reason)
      end

      def test_equality
        skip("Diff re-write")
        s2 = Conflict.new(@base_local_diffs, @base_remote_diffs, @reason)
        assert_equal @subject, s2
      end
    end
  end
end
