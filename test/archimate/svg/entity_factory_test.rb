# frozen_string_literal: true

require 'test_helper'

module Archimate
  module Svg
    class EntityFactoryTest < Minitest::Test
      BadEntity = Struct.new(:type) do
        include DataModel::Comparison
        include DataModel::Referenceable
      end

      def test_invalid_entity
        view_node = build_view_node(element: BadEntity.new("bogus"))
        assert_raises NameError do
          EntityFactory.make_entity(view_node, DataModel::Bounds.new(width: 10, height: 10))
        end
      end
    end
  end
end
