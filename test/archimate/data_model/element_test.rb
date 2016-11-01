# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class ElementTest < Minitest::Test
      def test_create
        el = Element.create(id: "abc123", label: "Me")
        assert_equal "Me", el.label
        assert_equal "abc123", el.id
        assert_nil el.type
      end

      def test_with
        el = Element.create(id: "abc123", label: "Me")
        assert_nil el.type
        el2 = el.with(type: "DataObject")
        assert_equal "DataObject", el2.type
      end

      def test_to_s
        el = Element.create(id: "abc123", type: "DataObject", label: "Thing")
        assert_equal "DataObject<abc123> Thing docs[0] props[0]", el.to_s
      end

      def test_short_desc
        el = Element.create(id: "abc123", type: "DataObject", label: "Thing")
        assert_equal "DataObject<abc123>[Thing]", el.short_desc.uncolorize
      end

      def test_to_id_string
        el = Element.create(id: "abc123", type: "DataObject", label: "Thing")
        assert_equal "DataObject<abc123>", el.to_id_string
      end

      def test_layer
        el = Element.create(id: "abc123", type: "BusinessRole", label: "Thing")
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
    end
  end
end
