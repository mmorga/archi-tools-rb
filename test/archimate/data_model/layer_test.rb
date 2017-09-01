# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class LayerTest < Minitest::Test
      def test_eqleql_operator
        @layer1 = Layer.new("Apple")
        @layer2 = Layer.new("Apple")
        assert_equal @layer1, @layer2
      end

      def test_case_comparison_operator
        @layer1 = Layer.new("Apple")
        @layer2 = Layer.new("Apple")
        assert @layer1 === @layer2
        assert @layer1 === :apple
        assert @layer1 === "Apple"
      end
    end
  end
end
