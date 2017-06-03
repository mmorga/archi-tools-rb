# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class ConflictsTest < Minitest::Test
      def test_new
        subject = Conflicts.new([], [])

        assert_empty subject.conflicting_diffs
        assert_equal "Conflicts:\n\n\n", subject.to_s
      end
    end
  end
end
