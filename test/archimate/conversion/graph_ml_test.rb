# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Conversion
    class GraphMLTest < Minitest::Test
      def test_me
        graph_ml = GraphML.new
        refute_nil graph_ml
      end
    end
  end
end
