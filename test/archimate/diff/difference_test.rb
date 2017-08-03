# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class DifferenceTest < Minitest::Test
      attr_accessor :model, :to_model

      def setup
        skip("Diff re-write")
        @model = build_model(with_relationships: 2, with_organizations: 2, with_diagrams: 2)
        @to_model = build_model
      end

      def test_change
        skip("Diff re-write")
        organization = model.organizations.first
        remote = model.with(
          diagrams: [
            model.diagrams[0].with(
              nodes: [build_view_node] + model.diagrams[0].nodes
            )
          ]
        )

        change_diff = Change.new(ArchimateNodeAttributeReference.new(organization, :name), ArchimateNodeAttributeReference.new(organization, :name))
        insert_diff = Insert.new(ArchimateArrayReference.new(remote.diagrams[0].nodes, 0))

        assert change_diff.change?
        refute change_diff.insert?

        assert insert_diff.insert?
        refute insert_diff.change?
      end

      def test_sort
        skip("Diff re-write")
        paths = [
          "Model<bee5a0a7>/diagrams/[52]/nodes/[0]/bounds/x",
          "Model<bee5a0a7>/diagrams/[52]/nodes/[1]/bounds/width",
          "Model<bee5a0a7>/diagrams/[52]/nodes/[1]/bounds/x",
          "Model<bee5a0a7>/diagrams/[52]/nodes/[1]/bounds/y",
          "Model<bee5a0a7>/diagrams/[52]/nodes/[2]/bounds/width",
          "Model<bee5a0a7>/diagrams/[52]/nodes/[2]/target_connections",
          "Model<bee5a0a7>/diagrams/[64]/nodes/[0]/nodes/[1]/element",
          "Model<bee5a0a7>/diagrams/[74]/nodes/[2]/nodes/[2]/element",
          "Model<bee5a0a7>/diagrams/[90]/nodes/[7]/element",
          "Model<bee5a0a7>/diagrams/[90]/nodes/[0]/element",
          "Model<bee5a0a7>/elements/[1032]/name",
          "Model<bee5a0a7>/elements/[135]/name",
          "Model<bee5a0a7>/elements/[1430]/name",
          "Model<bee5a0a7>/elements/[3]/name",
          "Model<bee5a0a7>/relationships/[1009]/source",
          "Model<bee5a0a7>/relationships/[100]/target",
          "Model<bee5a0a7>/relationships/[4]/source",
          "Model<bee5a0a7>/diagrams/[121]/nodes/[4]/nodes/[0]/element",
          "Model<bee5a0a7>/diagrams/[121]/nodes/[4]/element",
          "Model<bee5a0a7>/relationships/[5689]",
          "Model<bee5a0a7>/organizations/[8]/items/[46]",
          "Model<bee5a0a7>/organizations/[8]/items/[35]",
          "Model<bee5a0a7>/organizations/[8]/organizations/[9]/organizations/[2]",
          "Model<bee5a0a7>/organizations/[8]/organizations/[6]/organizations/[5]",
          "Model<bee5a0a7>/organizations/[8]/organizations/[6]/organizations/[4]",
          "Model<bee5a0a7>/organizations/[8]/organizations/[37]",
          "Model<bee5a0a7>/organizations/[8]/organizations/[33]/items/[2]",
          "Model<bee5a0a7>/organizations/[8]/organizations/[1]/organizations/[1]/organizations/[0]",
          "Model<bee5a0a7>/organizations/[7]/items/[28]",
          "Model<bee5a0a7>/organizations/[6]/items/[6978]",
          "Model<bee5a0a7>/organizations/[6]/items/[6976]",
          "Model<bee5a0a7>/elements/[1483]"
        ]
        expected_paths = [
          "Model<bee5a0a7>/elements/[3]/name",
          "Model<bee5a0a7>/elements/[135]/name",
          "Model<bee5a0a7>/elements/[1032]/name",
          "Model<bee5a0a7>/elements/[1430]/name",
          "Model<bee5a0a7>/elements/[1483]",
          "Model<bee5a0a7>/relationships/[4]/source",
          "Model<bee5a0a7>/relationships/[100]/target",
          "Model<bee5a0a7>/relationships/[1009]/source",
          "Model<bee5a0a7>/relationships/[5689]",
          "Model<bee5a0a7>/diagrams/[52]/nodes/[0]/bounds/x",
          "Model<bee5a0a7>/diagrams/[52]/nodes/[1]/bounds/width",
          "Model<bee5a0a7>/diagrams/[52]/nodes/[1]/bounds/x",
          "Model<bee5a0a7>/diagrams/[52]/nodes/[1]/bounds/y",
          "Model<bee5a0a7>/diagrams/[52]/nodes/[2]/bounds/width",
          "Model<bee5a0a7>/diagrams/[52]/nodes/[2]/target_connections",
          "Model<bee5a0a7>/diagrams/[64]/nodes/[0]/nodes/[1]/element",
          "Model<bee5a0a7>/diagrams/[74]/nodes/[2]/nodes/[2]/element",
          "Model<bee5a0a7>/diagrams/[90]/nodes/[0]/element",
          "Model<bee5a0a7>/diagrams/[90]/nodes/[7]/element",
          "Model<bee5a0a7>/diagrams/[121]/nodes/[4]/element",
          "Model<bee5a0a7>/diagrams/[121]/nodes/[4]/nodes/[0]/element",
          "Model<bee5a0a7>/organizations/[6]/items/[6976]",
          "Model<bee5a0a7>/organizations/[6]/items/[6978]",
          "Model<bee5a0a7>/organizations/[7]/items/[28]",
          "Model<bee5a0a7>/organizations/[8]/organizations/[1]/organizations/[1]/organizations/[0]",
          "Model<bee5a0a7>/organizations/[8]/organizations/[6]/organizations/[4]",
          "Model<bee5a0a7>/organizations/[8]/organizations/[6]/organizations/[5]",
          "Model<bee5a0a7>/organizations/[8]/organizations/[9]/organizations/[2]",
          "Model<bee5a0a7>/organizations/[8]/organizations/[33]/items/[2]",
          "Model<bee5a0a7>/organizations/[8]/organizations/[37]",
          "Model<bee5a0a7>/organizations/[8]/items/[35]",
          "Model<bee5a0a7>/organizations/[8]/items/[46]"
        ]
        diffs = paths.map { |p| Delete.new(p, model, "n/a") }

        result = diffs.sort

        assert_equal expected_paths, result.map(&:path)
      end

      def test_sort_bounds_attributes
        skip("Diff re-write")
        bounds = model.diagrams.first.nodes.first.bounds
        d1 = Delete.new(ArchimateNodeAttributeReference.new(bounds, :x))
        d2 = Delete.new(ArchimateNodeAttributeReference.new(bounds, :width))
        expected = [d2, d1]

        assert_equal expected, [d1, d2].sort
        assert_equal expected, [d2, d1].sort
      end

      def test_sort_elements_index
        skip("Diff re-write")
        skip "sorting isn't working yet"
        d1 = Delete.new(ArchimateNodeAttributeReference.new(model.elements.last, :name))
        d2 = Delete.new(ArchimateNodeAttributeReference.new(model.elements.first, :name))
        expected = [d2, d1]

        assert_equal expected, [d1, d2].sort
        assert_equal expected, [d2, d1].sort
      end

      def test_path
        skip("Diff re-write")
        d1 = Delete.new(ArchimateNodeAttributeReference.new(model, :name))

        assert_equal("name", d1.path)
      end

      def test_bounds_path
        skip("Diff re-write")
        bounds = model.diagrams.first.nodes.first.bounds
        d1 = Delete.new(ArchimateNodeAttributeReference.new(bounds, :x))

        assert_equal(
          "diagrams/#{model.diagrams.first.id}/nodes/#{model.diagrams.first.nodes.first.id}/bounds/x",
          d1.path
        )
      end

      def test_type_query_method_helpers
        skip("Diff re-write")
        d1 = Difference.new(
          ArchimateNodeAttributeReference.new(@model, :name),
          nil
        )

        refute d1.insert?
        refute d1.delete?
        refute d1.change?
        refute d1.move?
      end
    end
  end
end
