# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class WithTest < Minitest::Test
      def test_with
        m = build_model
        m2 = m.with(name: m.name + "-changed")
        refute_equal m, m2
        m.comparison_attributes.reject { |a| a == :@name }.each do |a|
          assert_equal m.instance_variable_get(a), m2.instance_variable_get(a)
        end
      end

      def test_in_model
        m = build_model(with_elements: 3, with_relationships: 2, with_diagrams: 1)
        m.elements.each { |e| assert_equal m, e.in_model }
      end

      def test_parent
        m = build_model(with_elements: 3, with_relationships: 2, with_diagrams: 1)
        m.elements.each { |e| assert_equal m.id, e.parent_id }
        m.elements.each { |e| assert_equal m, e.parent }
      end

      def test_assign_model
        @src_el = build_element
        @target_el = build_element
        @rel = build_relationship(source: @src_el.id, target: @src_el.id)
        @subject = build_source_connection(
          id: "abc123",
          type: "three",
          name: "test_name",
          source: "source",
          target: "target",
          relationship: "complicated"
        )
        @model = build_model(
          elements: [@src_el, @target_el],
          relationships: [@rel],
          diagrams: [
            build_diagram(
              children: [
                build_child(
                  source_connections: [@subject]
                )
              ]
            )
          ]
        )

        validate_in_model(@model)
      end

      private

      def validate_in_model(node)
        case node
        when Dry::Struct
          assert_equal(
            @model.id, node.in_model&.id, "node #{node.class} in_model #{node.in_model.id} != #{@model.id}"
          ) unless node.is_a?(Model)
          node.comparison_attributes.each do |a|
            validate_in_model(node.instance_variable_get(a))
          end
        when Array
          node.each { |c| validate_in_model(c) }
        end
      end
    end
  end
end
