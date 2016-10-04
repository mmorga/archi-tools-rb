# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Cli
    class SvgerTest < Minitest::Test
      def test_me
        svger = Svger.new
        refute_nil svger
      end
    end
  end
end
