# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class DiagramTest < Minitest::Test
      def test_new
        docs = build_documentation_list(count: 2)
        diagram = Diagram.new(id: "123", name: "my diagram", documentation: docs)
        assert_equal "123", diagram.id
        assert_equal "my diagram", diagram.name
        assert_equal docs, diagram.documentation
        assert_empty diagram.properties
        assert_empty diagram.children
      end
    end
  end
end
