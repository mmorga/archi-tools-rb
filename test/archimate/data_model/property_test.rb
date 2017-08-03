# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class PropertyTest < Minitest::Test
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

      def test_property_factory
        prop_def = build_property_definition
        subject = build_property(property_definition: prop_def)
        refute_empty subject.value
        assert_equal prop_def, subject.property_definition
      end

      def test_to_s
        subject = build_property
        result = subject.to_s

        assert_match "Property", result
        assert_match subject.key, result
        assert_match subject.value, result
      end
    end
  end
end
