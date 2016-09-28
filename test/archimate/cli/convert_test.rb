# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Cli
    class ConvertTest < Minitest::Test
      def test_new
        convert = Convert.new(AIO.new(verbose: true))
        assert_kind_of AIO, convert.instance_variable_get(:@io)
      end
    end
  end
end
