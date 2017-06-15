# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class ArchimateNodeReferenceTest < Minitest::Test
      using DataModel::DiffableArray

      def setup
        @model = build_model(with_relationships: 2, with_diagrams: 2, with_elements: 3, with_organizations: 4, with_documentation: 2)
        @bounds = @model.find_by_class(DataModel::Bounds).first
        @subject = ArchimateNodeAttributeReference.new(@bounds.parent, :bounds)
        @other = @model.clone
        @other_bounds = @other.find_by_class(DataModel::Bounds).first
      end

      def test_initialize
        assert_same @bounds, @subject.value
      end

      def test_equality
        doc1 = build_documentation
        doc1_clone = doc1.clone
        doc2 = build_documentation

        assert_equal doc1, doc1_clone
        refute_equal doc1, doc2
      end

      def test_lookup_in_model
        assert_same @other, ArchimateReferenceableReference.new(@model).lookup_in_model(@other)
      end

      def test_lookup_in_model_string_attribute
        assert_same @other.id, ArchimateNodeAttributeReference.new(@model, :id).lookup_in_model(@other)
      end

      def test_lookup_in_model_documentation
        assert_same @other, ArchimateReferenceableReference.new(@model).lookup_in_model(@other)
        assert_same @other.documentation, ArchimateNodeAttributeReference.new(@model, :documentation).lookup_in_model(@other)
        assert_equal 2, @other.documentation.size
        refute_nil @other.documentation[0]
        refute_nil @other.documentation[1]
        assert_same @other.documentation[0], ArchimateArrayReference.new(@model.documentation, 0).lookup_in_model(@other)
        assert_same @other.documentation[1], ArchimateArrayReference.new(@model.documentation, 1).lookup_in_model(@other)
      end

      def test_lookup_in_model_for_bounds
        assert_same @other_bounds, @subject.lookup_in_model(@other)
      end

      def test_lookup_parent_in_model
        assert_same @other_bounds.parent, @subject.lookup_parent_in_model(@other)
      end

      def test_lookup_parent_in_model_for_documentation
        subject = ArchimateArrayReference.new(@model.documentation, 1)

        assert_same @other.documentation[1], subject.lookup_in_model(@other)
        assert_same(
          @other.documentation,
          subject.lookup_parent_in_model(@other)
        )
      end

      def test_parent
        assert_same @bounds.parent, @subject.parent
      end

      def test_to_s
        assert_equal "bounds", @subject.to_s
      end

      def test_value
        assert_same @bounds, @subject.value
      end

      def test_path
        assert_equal "diagrams/#{@model.diagrams.first.id}/nodes/#{@model.diagrams.first.nodes.first.id}/bounds", @subject.path
      end
    end
  end
end
