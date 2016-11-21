# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class ChildTest < Minitest::Test
      def setup
        @model = build_model(diagrams: build_diagram_list(with_diagrams: 1))
        @subject = build_child(
          with_children: 3,
          relationships: build_relationship_list(with_relationships: 2)
        )
      end

      def test_create
        child = Child.create(parent_id: build_id, id: "abc123", type: "Sagitarius")
        assert_equal "abc123", child.id
        assert_equal "Sagitarius", child.type
        [:id, :type, :model, :name,
         :target_connections, :archimate_element, :bounds, :children,
         :source_connections].each { |sym| assert child.respond_to?(sym) }
      end

      def test_clone
        s2 = @subject.clone
        assert_equal @subject, s2
        refute_equal @subject.object_id, s2.object_id
      end

      def test_comparison_attributes
        assert_equal(
          [
            :@id, :@type, :@model, :@name, :@content, :@target_connections,
            :@archimate_element, :@bounds, :@children, :@source_connections,
            :@documentation, :@properties, :@style, :@child_type
          ],
          @subject.comparison_attributes
        )
      end

      def test_to_s
        assert_match(/Child/, @subject.to_s)
        assert_match("[#{@subject.name}]", @subject.to_s)
      end

      def test_relationships
        refute_empty @subject.relationships
      end

      def test_element_references
        expected = []
        expected << @subject.archimate_element
        expected.concat(@subject.children.map(&:archimate_element))
        assert_equal expected, @subject.element_references
      end

      def test_child_element
        skip("TODO")
        assert_equal @model.lookup(@element_id), @subject.element
      end
    end
  end
end
