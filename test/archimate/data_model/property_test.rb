# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class PropertyTest < Minitest::Test
      def test_create
        prop = Property.create(key: "keymaster", value: "gatekeeper")
        assert_equal "keymaster", prop.key
        assert_equal "gatekeeper", prop.value
      end

      def test_with
        prop = Property.create(key: "keymaster")
        assert_nil prop.value
        prop2 = prop.with(value: "gatekeeper")
        assert_equal "gatekeeper", prop2.value
      end
    end
  end
end
