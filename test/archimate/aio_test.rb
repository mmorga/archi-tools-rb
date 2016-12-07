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

    def test_error
      ioe = AIO.new(messages_io: StringIO.new)
      ioe.error "We want the funk"
      assert_equal "Error: We want the funk\n", HighLine.uncolor(ioe.messages_io.string)
    end

    def test_warning
      ioe = AIO.new(messages_io: StringIO.new)
      ioe.warning "We want the funk"
      assert_equal "Warning: We want the funk\n", HighLine.uncolor(ioe.messages_io.string)
    end

    def test_info
      ioe = AIO.new(messages_io: StringIO.new)
      ioe.info "We want the funk"
      assert_equal "We want the funk\n", HighLine.uncolor(ioe.messages_io.string)
    end

    def test_debug
      ioe = AIO.new(messages_io: StringIO.new, verbose: true)
      ioe.debug "Give us the funk"
      assert_match(/Debug: .+ Give us the funk\n/, HighLine.uncolor(ioe.messages_io.string))
    end
  end
end
