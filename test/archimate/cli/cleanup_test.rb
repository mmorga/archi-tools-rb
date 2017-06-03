# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Cli
    class CleanupTest < Minitest::Test
      def test_new
        model = build_model
        output = StringIO.new
        options = {}
        assert_kind_of Cleanup, Cleanup.new(model, output, options)
      end
    end
  end
end
