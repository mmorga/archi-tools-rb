# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class AnyAttributeTest < Minitest::Test
      def test_factory
        subject = build_any_attribute
        refute_empty subject.attribute
        assert_empty subject.prefix
        refute_empty subject.value
      end
    end
  end
end
