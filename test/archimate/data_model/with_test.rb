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
        model.struct_instance_variables.reject { |a| a == :name }.map { |a| "@#{a}" }.each do |a|
          assert_equal model.instance_variable_get(a), m2.instance_variable_get(a)
        end
      end

      def test_in_model
        model.elements.each { |e| assert_equal model, e.in_model }
      end

      def test_parent
        model.elements.each { |e| assert_equal model, e.parent }
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

      def test_struct_instance_variables
        assert_equal Model.schema.keys, model.struct_instance_variables
      end

      def test_struct_instance_variable_hash
        expected = {
          id: model.id,
          name: model.name,
          documentation: model.documentation,
          properties: model.properties,
          elements: model.elements,
          folders: model.folders,
          relationships: model.relationships,
          diagrams: model.diagrams
        }

        assert_equal expected, model.struct_instance_variable_hash
      end

      private

      def validate_in_model(node)
        case node
        when Dry::Struct
          assert_equal(
            @model.id, node.in_model&.id, "node #{node.class} in_model #{node.in_model.id} != #{@model.id}"
          ) unless node.is_a?(Model)
          node.struct_instance_variable_values.each { |a| validate_in_model(a) }
        when Array
          node.each { |c| validate_in_model(c) }
        end
      end
    end
  end
end
