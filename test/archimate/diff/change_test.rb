require 'test_helper'

module Archimate::Diff
  class ChangeTest < Minitest::Test
    def test_new
      change = Change.new(:delete, "Something")
      assert_equal :delete, change.kind
      assert_equal "Something", change.subject
    end
  end
end
