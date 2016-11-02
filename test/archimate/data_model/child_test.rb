# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class ChildTest < Minitest::Test
      def test_create
        child = Child.create(parent_id: build_id, id: "abc123", type: "Sagitarius")
        assert_equal "abc123", child.id
        assert_equal "Sagitarius", child.type
        [:id, :type, :model, :name,
         :target_connections, :archimate_element, :bounds, :children,
         :source_connections].each { |sym| assert child.respond_to?(sym) }
      end
    end
  end
end
