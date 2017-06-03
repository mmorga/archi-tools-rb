# frozen_string_literal: true
require 'test_helper'

module Archimate
  class AIOTest < Minitest::Test
    attr_reader :io

    def setup
      @io = AIO.new
    end

    def test_default_creation
      assert_equal $stdout, io.output_io
      assert_equal $stdin, io.input_io
      assert_equal $stdin, io.user_input_io
      assert_equal $stdout, io.messages_io
    end

    def test_verbose
      refute io.verbose
    end

    def test_force
      refute io.force
    end
  end
end
