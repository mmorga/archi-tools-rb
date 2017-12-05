# frozen_string_literal: true

require 'test_helper'

using Archimate::CoreRefinements

module Archimate
  class CoreRefinementsTest < Minitest::Test
    def test_snake_case
      assert_equal "danger_noodle_alert", "DangerNoodleAlert".snake_case
    end

    def test_eqeq_with_string
      assert_equal "some string", "some string"
      refute_equal "some string", "some other string"
    end

    def test_eqeq_with_lang_string
      # Note - since I'm testing == I have to use this form because
      # assert_equal expected, actual results in actual == expected
      assert("some string" == DataModel::LangString.new("some string"))
      refute("some string" == DataModel::LangString.new("other string"))
    end
  end
end
