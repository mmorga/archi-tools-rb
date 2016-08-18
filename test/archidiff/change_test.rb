require 'test_helper'

module Archidiff
  class ChangeTest < Minitest::Test
    def test_new
      change = Change.new(:delete, "Something")
      assert_equal :delete, change.kind
      assert_equal "Something", change.subject
    end
  end
end
