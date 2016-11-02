# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class PropertyTest < Minitest::Test
      def test_create
        prop = Property.create(parent_id: build_id, key: "keymaster", value: "gatekeeper")
        assert_equal "keymaster", prop.key
        assert_equal "gatekeeper", prop.value
      end

      def test_clone_with_value
        prop = build_property
        assert prop.value
        prop_clone = prop.clone
        refute_equal prop.object_id, prop_clone.object_id
      end

      def test_clone_without_value
        prop = build_property(value: nil)
        assert_nil prop.value
        prop_clone = prop.clone
        refute_equal prop.object_id, prop_clone.object_id
      end

      def test_with
        prop = build_property(key: "keymaster", value: nil)
        assert_nil prop.value
        prop2 = prop.with(value: "gatekeeper")
        assert_equal "gatekeeper", prop2.value
      end
    end
  end
end
