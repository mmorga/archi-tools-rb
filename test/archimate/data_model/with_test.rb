# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class WithTest < Minitest::Test
      attr_reader :model

      def setup
        @model = build_model(with_elements: 3, with_relationships: 2, with_diagrams: 1)
      end

      def test_with
        m2 = model.with(name: model.name + "-changed")
        refute_equal model, m2
        model.to_h.keys.reject { |a| a == :name }.map(&:to_sym).each do |a|
          assert_equal model.send(a), m2.send(a)
        end
      end

      def test_in_model
        model.elements.each { |e| assert_equal model, e.in_model }
      end

      def test_parent
        model.elements.each { |e| assert_equal model.elements, e.parent }
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

      def test_diff_with_changed_name
        m1 = build_model(with_relationships: 2, with_diagrams: 2, with_elements: 4, with_folders: 4)
        m2 = m1.with(name: "#{m1.name}-changed")

        diffs = m1.diff(m2)

        assert_equal 1, diffs.size
        assert diffs.first.change?
      end

      private

      def validate_in_model(node)
        case node
        when Dry::Struct
          assert_equal(
            @model.id, node.in_model&.id, "node #{node.class} in_model #{node.in_model.id} != #{@model.id}"
          ) unless node.is_a?(Model)
          node.to_h.values.each { |a| validate_in_model(a) }
        when Array
          node.each { |c| validate_in_model(c) }
        end
      end
    end
  end
end
