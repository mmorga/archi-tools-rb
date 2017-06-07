# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class PropertyTest < Minitest::Test
      def test_clone_with_value
        _prop_def, prop = build_property
        assert prop.value
        prop_clone = prop.clone
        refute_equal prop.object_id, prop_clone.object_id
      end

      def test_clone_without_value
        _prop_def, prop = build_property(value: nil)
        assert_nil prop.value
        prop_clone = prop.clone
        refute_equal prop.object_id, prop_clone.object_id
      end

      def test_to_s
        prop_def, subject = build_property
        _model = build_model(properties: [subject], property_definitions: [prop_def])
        result = subject.to_s

        assert_match "Property", result
        assert_match subject.key, result
        assert_match subject.value, result
      end
    end
  end
end
