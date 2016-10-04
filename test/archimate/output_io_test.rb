# frozen_string_literal: true
require 'test_helper'

module Archimate
  class OutputIOTest < Minitest::Test
    def test_new_default_io
      OutputIO.new({}, $stderr) { |io| assert_equal $stderr, io }
    end
  end
end
