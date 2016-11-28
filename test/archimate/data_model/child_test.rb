# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class ChildTest < Minitest::Test
      def setup
        @element = build_element
        @subject = build_child(
          with_children: 3,
          element: @element,
          relationships: build_relationship_list(with_relationships: 2)
        )
        @model = build_model(
          elements: [@element],
          diagrams: [
            build_diagram(
              children: [@subject]
            )
          ]
        )
        assert_equal @element.instance_variable_get(:@in_model), @model
        assert @model.instance_variable_get(:@index_hash).include?(@element.id)
        assert_equal @element, @model.elements[0]
        assert_equal @element.id, @subject.archimate_element
        assert_equal @model.diagrams[0].children[0], @subject
      end

      def test_create
        child = Child.create(id: "abc123", type: "Sagitarius")
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
        assert_equal @element, @subject.element
      end
    end
  end
end
