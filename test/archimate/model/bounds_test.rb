# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Model
    class BoundsTest < Minitest::Test
      def test_new
        b = Bounds.new(0, 10, 500, 700)
        assert_equal 0, b.x
        assert_equal 10, b.y
        assert_equal 500, b.width
        assert_equal 700, b.height
      end
    end
  end
end
