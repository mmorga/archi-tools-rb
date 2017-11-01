# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class ConnectionTest < Minitest::Test
      attr_reader :subject

      def setup
        src_el = build_element
        target_el = build_element
        @subject = build_connection(
          id: "abc123",
          name: LangString.new("test_name"),
          type: "three",
          source: nil,
          target: nil,
          relationship: build_relationship(source: src_el, target: target_el)
        )
      end

      def test_factory
        build_connection
      end

      def test_to_s
        assert_match("Connection", subject.to_s)
        assert_match("[#{subject.name}]", Archimate::Color.uncolor(subject.to_s))
      end

      def test_to_s_with_no_model
        @subject = build_connection
        assert_match("[#{subject.name}]", Archimate::Color.uncolor(subject.to_s))
      end

      def test_referenced_identified_nodes
        source = build_view_node(id: "a", element: build_element(id: "d"))
        target = build_view_node(id: "b", element: build_element(id: "e"))
        relationship = build_relationship(id: "c", source: source.element, target: target.element)
        subject = build_connection(
          source: source,
          target: target,
          relationship: relationship
        )

        rsrc, rtar, rrel = subject.referenced_identified_nodes
        assert_equal source, rsrc
        assert_equal target, rtar
        assert_equal relationship, rrel

        assert_equal %w(a b c), subject.referenced_identified_nodes.map(&:id).sort
      end
    end
  end
end
