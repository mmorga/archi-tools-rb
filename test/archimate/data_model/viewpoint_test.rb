# frozen_string_literal: true

require 'test_helper'

module Archimate
  module DataModel
    class ViewpointTest < Minitest::Test
      attr_reader :vp

      def setup
        @vp = Viewpoint.new(id: "123", name: LangString.new("omnipotent"))
      end

      def test_constructor
        assert_equal "omnipotent", vp.name.to_s
        refute_nil vp
      end

      TestParent = Struct.new(:list)

      def test_referenceable
        parent = TestParent.new([])
        parent.list = ReferenceableList.new(parent, [vp])
        assert_includes vp.references, parent
      end
    end
  end
end
