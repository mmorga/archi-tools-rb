# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class ConflictsTest < Minitest::Test
      def test_new
        @aio = Archimate::AIO.new(verbose: false, interactive: false)
        subject = Conflicts.new([], [], @aio)

        assert_empty subject.conflicting_diffs
        assert_equal "Conflicts:\n\n\n", subject.to_s
      end
    end
  end
end
