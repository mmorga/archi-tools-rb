# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class ViewNodeTest < Minitest::Test
      def setup
        @element = build_element
        @subject = build_view_node(
          with_nodes: 3,
          element: @element,
          relationships: build_relationship_list(with_relationships: 2)
        )
        @model = build_model(
          elements: [@element],
          diagrams: [
            build_diagram(
              nodes: [@subject]
            )
          ]
        )
        assert_equal @element.instance_variable_get(:@in_model), @model
        assert @model.instance_variable_get(:@index_hash).include?(@element.id)
        assert_equal @element, @model.elements[0]
        assert_equal @element.id, @subject.archimate_element
        assert_equal @model.diagrams[0].nodes[0], @subject
      end

      def test_new_defaults
        view_node = ViewNode.new(id: "abc123", type: "Sagitarius")
        assert_equal "abc123", view_node.id
        assert_equal "Sagitarius", view_node.type
        [:id, :type, :model, :name,
         :target_connections, :archimate_element, :bounds, :nodes,
         :connections].each { |sym| assert view_node.respond_to?(sym) }
      end

      def test_clone
        s2 = @subject.clone
        assert_equal @subject, s2
        refute_equal @subject.object_id, s2.object_id
      end

      def test_to_s
        assert_match(/ViewNode/, @subject.to_s)
        assert_match("[#{@subject.name}]", @subject.to_s)
      end

      def test_view_node_element
        assert_equal @element, @subject.element
      end

      def test_connections
        assert_kind_of Array, @subject.target_connections
        connections = @model.find_by_class(Connection)
        assert connections.size.positive?
        nodes = @model.find_by_class(ViewNode)
        assert nodes.size.positive?

        nodes.each do |view_node|
          # assert view_node.connections.size > 0
          assert view_node.connections.all? do |connection_id|
            assert_kind_of String, connection_id
            assert_kind_of Connection, @model.lookup(connection_id)
          end
        end
      end

      def test_referenced_identified_nodes
        subject = build_view_node(
          target_connections: %w(a b c),
          archimate_element: "d",
          nodes: [
            build_view_node(
              target_connections: %w(e),
              archimate_element: "f",
              connections: [
                build_connection(
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
