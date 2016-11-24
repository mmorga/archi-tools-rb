# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class ConstantsTest < Minitest::Test
      def test_element_list
        assert_includes Constants.constants, :ELEMENTS
      end

      def test_relationships_list
        assert_includes Constants.constants, :RELATIONSHIPS
      end

      def test_element_layer
        Constants::ELEMENT_LAYER.each do |el, layer|
          assert_kind_of String, el
          assert_kind_of String, layer
        end
      end
    end
  end
end
