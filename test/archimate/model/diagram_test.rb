# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Model
    class DiagramTest < Minitest::Test
      def test_new
        diagram = Diagram.create(id: "123", name: "my diagram", documentation: %w(documentation1 documentation2))
        assert_equal "123", diagram.id
        assert_equal "my diagram", diagram.name
        assert_equal %w(documentation1 documentation2), diagram.documentation
        assert_empty diagram.properties
        assert_empty diagram.children
      end
    end
  end
end
