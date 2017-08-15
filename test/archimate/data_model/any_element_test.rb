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

      def test_constructor
        subject = AnyElement.new(
          element: "el",
          prefix: "a",
          attributes: ["b"],
          content: "c",
          children: ["d"]
        )
        assert_equal "el", subject.element
        assert_equal "a", subject.prefix
        assert_equal ["b"], subject.attributes
        assert_equal "c", subject.content
        assert_equal ["d"], subject.children
      end
    end
  end
end
