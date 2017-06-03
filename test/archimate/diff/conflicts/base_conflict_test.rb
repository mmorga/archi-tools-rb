# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class Conflicts
      class BaseConflictTest < Minitest::Test
        def setup
          @subject = BaseConflict.new([], [])
        end

        def test_default_filters
          assert @subject.filter1.call("anything")
          assert @subject.filter2.call("anything")
        end
      end
    end
  end
end
