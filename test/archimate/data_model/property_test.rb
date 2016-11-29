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
