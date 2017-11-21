# frozen_string_literal: true

require 'test_helper'

class HelpTest < Minitest::Test
  def test_help
    result = `bin/archimate`
    assert_match(/Commands:/, result)
  end

  def test_help_clean
    result = `bin/archimate help clean`
    assert_match(/Usage:/, result)
    assert_match(/archimate clean ARCHIFILE/, result)
  end
end
