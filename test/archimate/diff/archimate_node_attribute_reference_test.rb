# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class ArchimateNodeAttributeReferenceTest < Minitest::Test
      using DataModel::DiffableArray

      def setup
        @model = build_model(with_relationships: 2, with_diagrams: 2, with_elements: 3, with_organizations: 4)
        @bounds = @model.find_by_class(DataModel::Bounds).first
        @subject = ArchimateNodeAttributeReference.new(@model, :name)
        @other = @model.clone
        @other_bounds = @other.find_by_class(DataModel::Bounds).first
      end

      def test_initialize
        assert_same @model, @subject.archimate_node
        assert_equal :name, @subject.attribute
      end

      def test_lookup_in_model_model
        assert_same @other, ArchimateReferenceableReference.new(@model).lookup_in_model(@other)
      end

      def test_lookup_in_model_name
        assert_same @other.name, @subject.lookup_in_model(@other)
      end

      def test_lookup_array_attribute
        assert_same(
          @other.documentation,
          ArchimateNodeAttributeReference.new(@model, :documentation).lookup_in_model(@other)
        )
      end

      def test_lookup_in_model_for_model_name_attribute
        assert_same @other.name, @subject.lookup_in_model(@other)
      end

      def test_lookup_in_model_for_bounds
        assert_same @other_bounds, ArchimateNodeAttributeReference.new(@bounds.parent, :bounds).lookup_in_model(@other)
      end

      def test_parent
        assert_same @model, @subject.parent
      end

      def test_to_s
        assert_equal "name", @subject.to_s
      end

      def test_value
        assert_same @model.name, @subject.value
      end
    end
  end
end
