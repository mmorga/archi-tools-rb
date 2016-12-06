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

      def test_new_defaults
        child = Child.new(id: "abc123", type: "Sagitarius")
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

      def test_child_element
        assert_equal @element, @subject.element
      end

      def test_source_connections
        assert_kind_of Array, @subject.target_connections
        source_connections = @model.find_by_class(SourceConnection)
        assert source_connections.size.positive?
        children = @model.find_by_class(Child)
        assert children.size.positive?

        children.each do |child|
          # assert child.source_connections.size > 0
          assert child.source_connections.all? do |source_connection_id|
            puts "Checking a source connection"
            assert_kind_of String, source_connection_id
            assert_kind_of SourceConnection, @model.lookup(source_connection_id)
          end
        end
      end

      def test_referenced_identified_nodes
        subject = build_child(
          target_connections: %w(a b c),
          archimate_element: "d",
          children: [
            build_child(
              target_connections: %w(e),
              archimate_element: "f",
              source_connections: [
                build_source_connection(
                  source: "g",
                  target: "h",
                  relationship: "i"
                )
              ]
            )
          ]
        )

        assert_equal %w(a b c d e f g h i), subject.referenced_identified_nodes.sort
      end
    end
  end
end
