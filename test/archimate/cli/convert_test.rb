# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Cli
    class ConvertTest < Minitest::Test
      def test_new
        convert = Convert.new({verbose: true})
        assert convert.instance_variable_get(:@verbose)
      end
    end
  end
end
