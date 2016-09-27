# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Cli
    class CleanupTest < Minitest::Test
      def test_new
        input = StringIO.new
        output = StringIO.new
        options = {}
        assert_kind_of Cleanup, Cleanup.new(input, output, options)
      end
    end
  end
end
