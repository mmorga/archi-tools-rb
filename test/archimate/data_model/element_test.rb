# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class ElementTest < Minitest::Test
      def test_to_s
        el = build_element(id: "abc123", type: "DataObject", name: "Thing")
        assert_equal "DataObject<abc123>[Thing]", HighLine.uncolor(el.to_s)
      end

      def test_layer
        el = build_element(id: "abc123", type: "BusinessRole", name: "Thing")
        assert_equal "Business", el.layer
        el = el.with(type: "DataObject")
        assert_equal "Application", el.layer
        el = el.with(type: "Device")
        assert_equal "Technology", el.layer
        el = el.with(type: "Goal")
        assert_equal "Motivation", el.layer
        el = el.with(type: "Gap")
        assert_equal "Implementation and Migration", el.layer
        el = el.with(type: "Junction")
        assert_equal "Connectors", el.layer
        el = el.with(type: "Bogus")
        assert_equal "None", el.layer
      end

      def test_composed_by
        element = build_element
        composed_by_element = build_element
        composed_by_relationship = build_relationship(
          type: "CompositionRelationship",
          source: composed_by_element.id,
          target: element.id
        )
        _model = build_model(
          elements: [element, composed_by_element],
          relationships: [composed_by_relationship]
        )

        assert_equal [composed_by_element], element.composed_by
      end

      def test_composes
        element = build_element
        composed_by_element = build_element
        composed_by_relationship = build_relationship(
          type: "CompositionRelationship",
          source: composed_by_element.id,
          target: element.id
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
