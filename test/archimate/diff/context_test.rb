# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class ContextTest < Minitest::Test
      def test_new
        model1 = build_model
        model2 = build_model
        ctx = Context.new(model1, model2)
        assert_equal model1, ctx.model1
        assert_equal model2, ctx.model2
      end
    end
  end
end
