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
        # assert_equal @element.instance_variable_get(:@in_model), @model
        # assert @model.instance_variable_get(:@index_hash).include?(@element.id)
        # assert_equal @element, @model.elements[0]
        # assert_equal @element, @subject.element
        # assert_equal @model.diagrams[0].nodes[0], @subject
      end

      def test_factory
        build_view_node
      end

      def test_new_defaults
        diagram = build_diagram
        view_node = ViewNode.new(id: "abc123", type: "Sagitarius", diagram: diagram)
        assert_equal "abc123", view_node.id
        assert_equal "Sagitarius", view_node.type
        [:id, :type, :view_refs, :name,
         # :target_connections,
         :element, :bounds, :nodes,
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
        connections = @model.send(:find_by_class, Connection)
        assert connections.size.positive?
        nodes = @model.send(:find_by_class, ViewNode)
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
        source = build_element(id: "g")
        target = build_element(id: "h")
        relationship = build_relationship(id: "i")
        subject = build_view_node(
          element: build_element(id: "d"),
          nodes: [
            build_view_node(
              element: build_element(id: "f"),
              connections: [
                build_connection(
                  source: source,
                  target: target,
                  relationship: relationship
                )
              ]
            )
          ]
        )

        assert_equal %w(d f g h i), subject.referenced_identified_nodes.map(&:id).sort
      end
    end
  end
end
