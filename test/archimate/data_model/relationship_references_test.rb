# frozen_string_literal: true

require 'test_helper'

module Archimate
  module DataModel
    class RelationshipReferencesTest < Minitest::Test
      def setup
        @el1 = Elements::ApplicationComponent.new(id: "app-comp-1", name: "Application Component")
        @el2 = Elements::ApplicationInterface.new(id: "app-if-1", name: "Application API")
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

      def test_multiple_relationship_creation_helpers
        app_comp = Elements::ApplicationComponent.new(id: "app-comp-2", name: "My Application Component")
        @model.elements << app_comp
        el3 = Elements::ApplicationInterface.new(id: "app-if-3", name: "My Application API")
        @model.elements << el3
        el4 = Elements::ApplicationInterface.new(id: "app-if-4", name: "My Application Portal")
        @model.elements << el4
        rels = app_comp.composes([el3, el4])
        assert_equal 2, rels.size
        assert_equal el3, rels[0].target
        assert_equal el4, rels[1].target
        assert(rels.all? { |rel| rel.source == app_comp })
      end

      def test_create_rel_without_target
        app_comp = Elements::ApplicationComponent.new(id: "app-comp-2", name: "My Application Component")
        @model.elements << app_comp
        assert_nil app_comp.composes
      end

      def test_targetd_relationship_creation_helpers
        app_func = Elements::ApplicationFunction.new(id: "app-func-1", name: "Application Function")
        @model.elements << app_func
        rel = app_func.assigned_from(@el1)

        assert_kind_of Relationships::Assignment, rel
        assert_equal @el1, rel.source
        assert_equal app_func, rel.target

        assert_equal [rel], @el1.assigned_to_relationships
        assert_equal [rel], app_func.assigned_from_relationships
      end
    end
  end
end
