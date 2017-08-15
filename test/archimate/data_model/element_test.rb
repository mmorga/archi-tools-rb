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
        assert els.all? { |el| el.is_a?(Element) }
      end

      def test_to_s
        el = build_element(id: "abc123", type: "DataObject", name: "Thing")
        assert_equal "DataObject<abc123>[Thing]", Archimate::Color.uncolor(el.to_s)
      end

      def test_layer
        el = build_element(id: "abc123", type: "BusinessRole", name: "Thing")
        assert_equal "Business", el.layer
        el = Element.new(el.to_h.merge(type: "DataObject"))
        assert_equal "Application", el.layer
        el = Element.new(el.to_h.merge(type: "Device"))
        assert_equal "Technology", el.layer
        el = Element.new(el.to_h.merge(type: "Goal"))
        assert_equal "Motivation", el.layer
        el = Element.new(el.to_h.merge(type: "Gap"))
        assert_equal "Implementation and Migration", el.layer
        el = Element.new(el.to_h.merge(type: "Junction"))
        assert_equal "Connectors", el.layer
        el = Element.new(el.to_h.merge(type: "Bogus"))
        assert_equal "None", el.layer
      end

      def test_composed_by
        skip "until composed_by is added"
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

        assert_equal [composed_by_element], element.composed_by
      end

      def test_composes
        skip "until composes is added"
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

        assert_equal [element], composed_by_element.composes
      end
    end
  end
end
