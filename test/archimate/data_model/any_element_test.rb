# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class AnyElementTest < Minitest::Test
    	def test_factory
    		subject = build_any_element
    		refute_empty subject.element
    		assert_empty subject.prefix
        assert_empty subject.attributes
        assert_nil subject.content
    		assert_empty subject.children
    	end
    end
  end
end
