# frozen_string_literal: true

require 'test_helper'

module Archimate
  module DataModel
    class ViewpointTest < Minitest::Test
      def test_constructor
        vp = Viewpoint.new(id: "123", name: LangString.new("omnipotent"))
        assert_equal "omnipotent", vp.name.to_s
        refute_nil vp
      end
    end
  end
end
