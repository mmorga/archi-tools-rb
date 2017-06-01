# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Lint
    class DuplicateEntitiesTest < Minitest::Test
      def setup
        @model = build_model
        @subject = DuplicateEntities.new(@model)
      end

      def test_simplify
        assert_equal(@subject.send(:simplify, build_element(name: nil)), "")
        assert_equal(@subject.send(:simplify, build_element(name: "hello bob")), "bob")
        assert_equal(@subject.send(:simplify, build_element(name: "JellO")), "jello")
        assert_equal(@subject.send(:simplify, build_element(name: " \tJello World\n")), "jelloworld")
        assert_equal(@subject.send(:simplify, build_element(name: "&Jello-World;yeah!right?")), "jelloworldyeahright")
      end
    end
  end
end
