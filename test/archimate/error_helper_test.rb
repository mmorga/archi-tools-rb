# frozen_string_literal: true
require 'test_helper'

module Archimate
  class ErrorHelperTest < Minitest::Test
    include Archimate::ErrorHelper

    def test_error
      out, _err = capture_io do
        error "We want the funk"
      end

      assert_equal "Error: We want the funk\n", HighLine.uncolor(out)
    end

    def test_warning
      out, _err = capture_io do
        warning "We want the funk"
      end

      assert_equal "Warning: We want the funk\n", HighLine.uncolor(out)
    end

    def test_info
      out, _err = capture_io do
        info "We want the funk"
      end

      assert_equal "We want the funk\n", HighLine.uncolor(out)
    end
  end
end
