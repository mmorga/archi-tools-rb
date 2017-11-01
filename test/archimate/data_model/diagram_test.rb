# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class DiagramTest < Minitest::Test
      def test_new
        docs = build_documentation
        diagram = Diagram.new(id: "123", name: LangString.new("my diagram"), documentation: docs, type: "")
        assert_equal "123", diagram.id
        assert_equal "my diagram", diagram.name.to_s
        assert_equal docs, diagram.documentation
        assert_empty diagram.properties
        assert_empty diagram.nodes
      end

      def test_factory
        build_diagram
      end

      def test_factory_list
        diagrams = build_diagram_list(with_diagrams: 2)
        assert_kind_of Array, diagrams
        diagrams.each {|d| assert_kind_of Diagram, d }
      end
    end
  end
end
