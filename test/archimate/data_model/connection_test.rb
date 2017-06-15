# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class ConnectionTest < Minitest::Test
      attr_reader :subject

      def setup
        src_el = build_element
        target_el = build_element
        @model = build_model(
          elements: [src_el, target_el],
          relationships: [
            build_relationship(source: src_el.id, target: src_el.id)
          ],
          diagrams: [
            build_diagram(
              children: [
                build_child(
                  connections: [
                    build_connection(
                      id: "abc123",
                      type: "three",
                      name: "test_name",
                      source: src_el.id,
                      target: target_el.id,
                      relationship: "complicated"
                    )
                  ]
                )
              ]
            )
          ]
        )
        @subject = @model.diagrams[0].children[0].connections[0]
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
        subject = build_connection(
          source: "a",
          target: "b",
          relationship: "c"
        )

        assert_equal %w(a b c), subject.referenced_identified_nodes.sort
      end
    end
  end
end
