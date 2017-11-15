# frozen_string_literal: true

require 'test_helper'

module Archimate
  module DataModel
    class RelationshipReferencesTest < Minitest::Test
      def setup
        @el1 = Elements::ApplicationComponent.new(id: "app-comp-1", name: "Application Component")
        @el2 = Elements::ApplicationInterface.new(id: "app-if-1", name: "Application Interface")
        @rel = Relationships::Composition.new(id: "rel-1", source: @el1, target: @el2)
        @model = build_model(elements: [@el1, @el2], relationships: [@rel])
      end

      def test_relationship_dynamic_methods
        assert_equal 1, @el1.relationships.size
        assert_equal [@rel], @el1.composes_relationships
        assert_equal [@rel], @el2.composed_by_relationships
      end

      def test_relationship_creation_helpers
        app_func = Elements::ApplicationFunction.new(id: "app-func-1", name: "Application Function")
        @model.elements << app_func
        rel = @el1.assigned_to(app_func)

        assert_kind_of Relationships::Assignment, rel
        assert_equal @el1, rel.source
        assert_equal app_func, rel.target

        assert_equal [rel], @el1.assigned_to_relationships
        assert_equal [rel], app_func.assigned_from_relationships
      end
    end
  end
end
