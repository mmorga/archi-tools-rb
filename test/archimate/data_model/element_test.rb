# frozen_string_literal: true

require 'test_helper'

module Archimate
  module DataModel
    class ElementTest < Minitest::Test
      def test_factory
        build_element
      end

      def test_list_factory
        given_elements = [build_element]
        els = build_element_list(elements: given_elements, with_elements: 3, with_relationships: 3)
        assert_equal 6, els.size
        assert given_elements.all? { |el| els.include?(el) }
        assert(els.all? { |el| el.is_a?(Element) })
      end

      def test_to_s
        el = build_element(id: "abc123", type: "DataObject", name: "Thing")
        assert_equal "DataObject<abc123>[Thing]", Archimate::Color.uncolor(el.to_s)
      end

      def test_layer
        el = build_element(id: "abc123", type: "BusinessRole", name: "Thing")
        assert_equal Layers::Business, el.layer
        el = Elements::DataObject.new(el.to_h)
        assert_equal Layers::Application, el.layer
        el = Elements::Device.new(el.to_h)
        assert_equal Layers::Technology, el.layer
        el = Elements::Goal.new(el.to_h)
        assert_equal Layers::Motivation, el.layer
        el = Elements::Gap.new(el.to_h)
        assert_equal Layers::Implementation_and_migration, el.layer
        el = Elements::AndJunction.new(el.to_h)
        assert_equal Layers::Connectors, el.layer
      end

      def test_composed_by_relationships
        element = build_element
        composed_by_element = build_element
        composed_by_relationship = build_relationship(
          type: "CompositionRelationship",
          source: composed_by_element,
          target: element
        )
        _model = build_model(
          elements: [element, composed_by_element],
          relationships: [composed_by_relationship]
        )

        assert_equal [composed_by_element], element.composed_by_elements
        assert_equal [composed_by_relationship], element.composed_by_relationships
      end

      def test_composes_relationships
        element = build_element
        composed_by_element = build_element
        composed_by_relationship = build_relationship(
          type: "CompositionRelationship",
          source: composed_by_element,
          target: element
        )
        _model = build_model(
          elements: [element, composed_by_element],
          relationships: [composed_by_relationship]
        )

        assert_equal [element], composed_by_element.composes_elements
        assert_equal [composed_by_relationship], composed_by_element.composes_relationships
      end
    end
  end
end
