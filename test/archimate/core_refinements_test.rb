# frozen_string_literal: true

require 'test_helper'

using Archimate::CoreRefinements

module Archimate
  class CoreRefinementsTest < Minitest::Test
    def test_snake_case
      assert_equal "danger_noodle_alert", "DangerNoodleAlert".snake_case
    end
  end
end
