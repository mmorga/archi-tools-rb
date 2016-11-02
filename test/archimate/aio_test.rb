# frozen_string_literal: true
require 'test_helper'

module Archimate
  class AIOTest < Minitest::Test
    attr_reader :io

    def setup
      @io = AIO.new
    end

    def test_default_creation
      assert_equal $stdout, io.out
      assert_equal $stdin, io.in
      assert_equal $stdin, io.uin
      assert_equal $stderr, io.err
      assert_equal $stderr, io.uout
    end

    def test_verbose
      refute io.verbose
    end

    def test_force
      refute io.force
    end

    def test_error
      ioe = AIO.new(uout: StringIO.new)
      ioe.error "We want the funk"
      assert_equal "Error: We want the funk\n", HighLine.uncolor(ioe.uout.string)
    end

    def test_warning
      ioe = AIO.new(uout: StringIO.new)
      ioe.warning "We want the funk"
      assert_equal "Warning: We want the funk\n", HighLine.uncolor(ioe.uout.string)
    end

    def test_info
      ioe = AIO.new(uout: StringIO.new)
      ioe.info "We want the funk"
      assert_equal "We want the funk\n", HighLine.uncolor(ioe.uout.string)
    end

    def test_debug
      ioe = AIO.new(uout: StringIO.new, verbose: true)
      ioe.debug "Give us the funk"
      assert_match(/Debug: .+ Give us the funk\n/, HighLine.uncolor(ioe.uout.string))
    end
  end
end
